import 'package:flutter/material.dart';

import '../../models/feedback_entry.dart';
import '../../services/app_state.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_formatters.dart';
import '../../widgets/common/section_card.dart';

class FeedbackAdminScreen extends StatelessWidget {
  const FeedbackAdminScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final List<FeedbackEntry> feedbacks = appState.feedbacksData;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Feedback Layanan',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.slate900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Saran, kritik, dan masukan mengenai makanan MBG dari setiap kelas.',
            style: TextStyle(
              color: isDark ? AppColors.slate400 : AppColors.slate500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.rate_review_rounded, color: AppColors.emerald),
                    const SizedBox(width: 10),
                    Text(
                      'Semua Feedback (${feedbacks.length})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.slate900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (feedbacks.isEmpty)
                  const SizedBox(
                    height: 250,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 52,
                            color: AppColors.slate400,
                          ),
                          SizedBox(height: 14),
                          Text(
                            'Belum ada feedback yang dikirim.',
                            style: TextStyle(
                              color: AppColors.slate500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Feedback dari halaman pengembalian akan muncul di sini.',
                            style: TextStyle(
                              color: AppColors.slate400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: feedbacks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (BuildContext context, int index) {
                      final FeedbackEntry feedback = feedbacks[index];
                      final String dateStr = AppFormatters.formatLongDate(feedback.date);
                      final String timeStr = AppFormatters.formatShortTime(feedback.date);

                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.slate700 : AppColors.slate50,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark ? AppColors.slate600 : AppColors.slate200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.emeraldSoft,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    feedback.className,
                                    style: const TextStyle(
                                      color: AppColors.emeraldDark,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'PJ: ${feedback.pjName}',
                                    style: TextStyle(
                                      color: isDark
                                          ? AppColors.slate200
                                          : AppColors.slate700,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '$dateStr, $timeStr',
                                  style: const TextStyle(
                                    color: AppColors.slate400,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.slate800 : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.slate600
                                      : AppColors.slate100,
                                ),
                              ),
                              child: Text(
                                feedback.feedback,
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.slate100
                                      : AppColors.slate800,
                                  fontSize: 14,
                                  height: 1.5,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
