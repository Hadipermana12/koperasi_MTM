import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';
import '../models/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  // ── Icon & color per notification type ──────────────────────────
  Map<String, dynamic> _typeConfig(String? type) {
    switch (type) {
      case 'LOAN_APPROVED':
        return {
          'icon': Icons.check_circle_rounded,
          'color': const Color(0xFF22c55e),
          'bg': const Color(0xFFf0fdf4),
          'label': 'Disetujui',
        };
      case 'LOAN_REJECTED':
        return {
          'icon': Icons.cancel_rounded,
          'color': const Color(0xFFef4444),
          'bg': const Color(0xFFfef2f2),
          'label': 'Ditolak',
        };
      default:
        return {
          'icon': Icons.notifications_rounded,
          'color': const Color(0xFF3b82f6),
          'bg': const Color(0xFFeff6ff),
          'label': 'Info',
        };
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return DateFormat('d MMM yyyy', 'id_ID').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF0f172a)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0f172a),
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (_, prov, __) {
              if (prov.unreadCount == 0) return const SizedBox();
              return TextButton(
                onPressed: prov.markAllAsReadLocally,
                child: Text(
                  'Tandai Semua',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF005bb7),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFF1F5F9)),
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          // Loading
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFF005bb7),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Memuat notifikasi...',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94a3b8),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            );
          }

          // Error
          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.wifi_off_rounded, color: Color(0xFFef4444), size: 36),
                    ),
                    const SizedBox(height: 20),
                    const Text('Gagal memuat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0f172a))),
                    const SizedBox(height: 8),
                    Text(provider.error!, style: const TextStyle(fontSize: 13, color: Color(0xFF94a3b8)), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: provider.fetchNotifications,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Coba Lagi', style: TextStyle(fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005bb7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Empty
          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(Icons.notifications_off_rounded, color: Color(0xFF3b82f6), size: 48),
                  ),
                  const SizedBox(height: 20),
                  const Text('Belum ada notifikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0f172a))),
                  const SizedBox(height: 8),
                  const Text('Notifikasi pengajuan pinjaman\nakan muncul di sini.', style: TextStyle(fontSize: 13, color: Color(0xFF94a3b8), height: 1.6), textAlign: TextAlign.center),
                ],
              ),
            );
          }

          // Notification List
          return RefreshIndicator(
            onRefresh: provider.fetchNotifications,
            color: const Color(0xFF005bb7),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              itemCount: provider.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notif = provider.notifications[index];
                return _NotificationTile(
                  notif: notif,
                  typeConfig: _typeConfig(notif.type),
                  timeLabel: _formatDate(notif.createdAt),
                  onTap: () {
                    if (!notif.isRead) {
                      context.read<NotificationProvider>().markAsRead(notif.id);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/* ─── Notification Tile ────────────────────────────────────── */
class _NotificationTile extends StatelessWidget {
  final NotificationModel notif;
  final Map<String, dynamic> typeConfig;
  final String timeLabel;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notif,
    required this.typeConfig,
    required this.timeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : (typeConfig['bg'] as Color),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: notif.isRead ? const Color(0xFFF1F5F9) : (typeConfig['color'] as Color).withOpacity(0.25),
            width: notif.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(notif.isRead ? 0.03 : 0.06),
              blurRadius: notif.isRead ? 8 : 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: (typeConfig['color'] as Color).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  typeConfig['icon'] as IconData,
                  color: typeConfig['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w900,
                              color: const Color(0xFF0f172a),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: typeConfig['color'] as Color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (typeConfig['color'] as Color).withOpacity(0.4),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.message,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748b), height: 1.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (typeConfig['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            typeConfig['label'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: typeConfig['color'] as Color,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          timeLabel,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94a3b8), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
