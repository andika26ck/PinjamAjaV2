-- =============================================================
-- PinjamAja — Database Schema
-- =============================================================

-- PROFILES (extend auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  phone TEXT UNIQUE,
  role TEXT CHECK (role IN ('owner', 'renter')) DEFAULT NULL,
  avatar_url TEXT,
  rating DECIMAL(3,2) DEFAULT 0.0,
  total_transactions INT DEFAULT 0,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- CATEGORIES
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  icon_url TEXT,
  slug TEXT UNIQUE NOT NULL,
  item_count INT DEFAULT 0
);

-- ITEMS
CREATE TABLE items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  price_per_day DECIMAL(12,2) NOT NULL,
  deposit_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  image_urls TEXT[] DEFAULT '{}',
  condition TEXT CHECK (condition IN ('baru', 'sangat_baik', 'baik', 'cukup')),
  status TEXT CHECK (status IN ('available', 'unavailable', 'rented')) DEFAULT 'available',
  location TEXT,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  blocked_dates DATE[] DEFAULT '{}',
  rating DECIMAL(3,2) DEFAULT 0.0,
  total_reviews INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- BOOKINGS
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id UUID REFERENCES items(id) ON DELETE SET NULL,
  renter_id UUID REFERENCES profiles(id),
  owner_id UUID REFERENCES profiles(id),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  total_days INT GENERATED ALWAYS AS (end_date - start_date) STORED,
  price_per_day DECIMAL(12,2) NOT NULL,
  deposit_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  platform_fee DECIMAL(12,2) NOT NULL,
  total_price DECIMAL(12,2) NOT NULL,
  status TEXT CHECK (status IN ('pending', 'confirmed', 'active', 'completed', 'cancelled')) DEFAULT 'pending',
  payment_status TEXT CHECK (payment_status IN ('unpaid', 'paid', 'refunded')) DEFAULT 'unpaid',
  cancellation_reason TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT valid_dates CHECK (end_date > start_date)
);

-- REVIEWS
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID UNIQUE REFERENCES bookings(id) ON DELETE CASCADE,
  item_id UUID REFERENCES items(id) ON DELETE CASCADE,
  reviewer_id UUID REFERENCES profiles(id),
  rating SMALLINT CHECK (rating BETWEEN 1 AND 5) NOT NULL,
  comment TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- MESSAGES
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID REFERENCES profiles(id),
  receiver_id UUID REFERENCES profiles(id),
  booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- RLS POLICIES
-- profiles: user hanya bisa update profil sendiri
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public profiles are viewable by everyone"
  ON profiles FOR SELECT USING (TRUE);
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id);

-- items: semua bisa baca, hanya owner yang bisa insert/update/delete
ALTER TABLE items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Items are viewable by everyone"
  ON items FOR SELECT USING (TRUE);
CREATE POLICY "Owner can insert items"
  ON items FOR INSERT WITH CHECK (auth.uid() = owner_id);
CREATE POLICY "Owner can update own items"
  ON items FOR UPDATE USING (auth.uid() = owner_id);
CREATE POLICY "Owner can delete own items"
  ON items FOR DELETE USING (auth.uid() = owner_id);

-- bookings: hanya renter atau owner yang terlibat
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Booking visible to involved parties"
  ON bookings FOR SELECT
  USING (auth.uid() = renter_id OR auth.uid() = owner_id);
CREATE POLICY "Renter can create booking"
  ON bookings FOR INSERT WITH CHECK (auth.uid() = renter_id);
CREATE POLICY "Involved parties can update booking"
  ON bookings FOR UPDATE
  USING (auth.uid() = renter_id OR auth.uid() = owner_id);

-- messages: hanya sender atau receiver
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Messages visible to sender and receiver"
  ON messages FOR SELECT
  USING (auth.uid() = sender_id OR auth.uid() = receiver_id);
CREATE POLICY "Authenticated users can send messages"
  ON messages FOR INSERT WITH CHECK (auth.uid() = sender_id);
CREATE POLICY "Receiver can mark as read"
  ON messages FOR UPDATE USING (auth.uid() = receiver_id);

-- ENABLE REALTIME for messages table
ALTER PUBLICATION supabase_realtime ADD TABLE messages;

-- =============================================================
-- ADDITIONS — diperlukan agar ChatService benar-benar berfungsi
-- dan memenuhi acceptance criteria (bukan ada di spec asli)
-- =============================================================

-- Index pendukung query chat (ambil pesan per booking, hitung unread, dst.)
CREATE INDEX idx_messages_booking_timestamp ON messages (booking_id, "timestamp" DESC);
CREATE INDEX idx_messages_receiver_read ON messages (receiver_id, is_read) WHERE is_read = FALSE;

-- RPC: daftar percakapan unik milik user yang sedang login, di-group per
-- booking_id + lawan bicara, lengkap dengan pesan terakhir & unread count.
-- Memakai auth.uid() langsung (bukan parameter dari client) supaya RPC ini
-- tidak bisa dipakai untuk membaca inbox user lain.
CREATE OR REPLACE FUNCTION get_conversations()
RETURNS TABLE (
  booking_id UUID,
  other_user_id UUID,
  other_user_name TEXT,
  other_user_avatar TEXT,
  item_id UUID,
  item_title TEXT,
  last_message TEXT,
  last_message_time TIMESTAMPTZ,
  unread_count BIGINT
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
  SELECT
    convo.booking_id,
    other_user.id AS other_user_id,
    other_user.name AS other_user_name,
    other_user.avatar_url AS other_user_avatar,
    it.id AS item_id,
    it.title AS item_title,
    last_msg.message AS last_message,
    last_msg."timestamp" AS last_message_time,
    COALESCE(unread.unread_count, 0) AS unread_count
  FROM (
    SELECT DISTINCT
      booking_id,
      CASE WHEN sender_id = auth.uid() THEN receiver_id ELSE sender_id END AS other_id
    FROM messages
    WHERE sender_id = auth.uid() OR receiver_id = auth.uid()
  ) convo
  JOIN profiles other_user ON other_user.id = convo.other_id
  JOIN bookings b ON b.id = convo.booking_id
  LEFT JOIN items it ON it.id = b.item_id
  LEFT JOIN LATERAL (
    SELECT m.message, m."timestamp"
    FROM messages m
    WHERE m.booking_id = convo.booking_id
    ORDER BY m."timestamp" DESC
    LIMIT 1
  ) last_msg ON TRUE
  LEFT JOIN LATERAL (
    SELECT COUNT(*) AS unread_count
    FROM messages m
    WHERE m.booking_id = convo.booking_id
      AND m.receiver_id = auth.uid()
      AND m.sender_id = convo.other_id
      AND m.is_read = FALSE
  ) unread ON TRUE
  ORDER BY last_msg."timestamp" DESC NULLS LAST;
$$;

GRANT EXECUTE ON FUNCTION get_conversations() TO authenticated;

-- STORAGE BUCKETS
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('item-images', 'item-images', TRUE, 5242880, ARRAY['image/jpeg', 'image/png']),
  ('avatars', 'avatars', TRUE, 2097152, ARRAY['image/jpeg', 'image/png'])
ON CONFLICT (id) DO NOTHING;

-- STORAGE POLICIES
-- item-images: publik dibaca, hanya pemilik file (uploader) yang bisa ubah/hapus
CREATE POLICY "Item images are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'item-images');
CREATE POLICY "Authenticated users can upload item images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'item-images' AND auth.role() = 'authenticated');
CREATE POLICY "Uploader can update their item images"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'item-images' AND auth.uid() = owner);
CREATE POLICY "Uploader can delete their item images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'item-images' AND auth.uid() = owner);

-- avatars: publik dibaca, hanya pemilik file (uploader) yang bisa ubah/hapus
CREATE POLICY "Avatars are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');
CREATE POLICY "Authenticated users can upload their avatar"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'avatars' AND auth.role() = 'authenticated');
CREATE POLICY "Uploader can update their avatar"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'avatars' AND auth.uid() = owner);
CREATE POLICY "Uploader can delete their avatar"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'avatars' AND auth.uid() = owner);
