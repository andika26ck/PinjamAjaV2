/// Model laporan pengguna (tabel `reports`).
class Report {
  final String id;
  final String reporterId;
  final String targetType; // item | user | review | chat
  final String targetId;
  final String reason;
  final String? description;
  final String status; // open | reviewing | resolved | dismissed
  final String? adminNote;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final DateTime? createdAt;

  const Report({
    required this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.description,
    this.status = 'open',
    this.adminNote,
    this.resolvedBy,
    this.resolvedAt,
    this.createdAt,
  });

  bool get isOpen => status == 'open' || status == 'reviewing';

  String get statusLabel => switch (status) {
        'open' => 'Baru',
        'reviewing' => 'Ditinjau',
        'resolved' => 'Selesai',
        'dismissed' => 'Diabaikan',
        _ => status,
      };

  String get targetTypeLabel => switch (targetType) {
        'item' => 'Barang',
        'user' => 'Pengguna',
        'review' => 'Ulasan',
        'chat' => 'Chat',
        _ => targetType,
      };

  factory Report.fromJson(Map<String, dynamic> json) {
    DateTime? p(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());
    return Report(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String? ?? '',
      targetType: json['target_type'] as String? ?? 'item',
      targetId: json['target_id'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'open',
      adminNote: json['admin_note'] as String?,
      resolvedBy: json['resolved_by'] as String?,
      resolvedAt: p(json['resolved_at']),
      createdAt: p(json['created_at']),
    );
  }
}