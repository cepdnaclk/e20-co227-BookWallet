import 'package:book_wallert/colors.dart';
import 'package:book_wallert/controllers/notiffication_controller.dart';
import 'package:book_wallert/controllers/review_controller.dart';
import 'package:book_wallert/models/review_model.dart';
import 'package:book_wallert/services/notification_api_service.dart';
import 'package:book_wallert/widgets/cards/review_card.dart';
import 'package:flutter/material.dart';

class NotificationAllListView extends StatelessWidget {
  final int globalUserId;
  final NotificationController _notificationController =
      NotificationController();
  final ReviewController _reviewController = ReviewController();

  NotificationAllListView({Key? key, required this.globalUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _notificationController.getAllNotifications(globalUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error fetching notifications"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No notifications"));
        }

        final notifications = snapshot.data as List<AppNotificationAll>;

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];

            return GestureDetector(
              onTap: () async {
                // Fetch the review details when the card is clicked
                ReviewModel review =
                    await _reviewController.fetchReview(notification.reviewID);

                // Show the review in a dialog box
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8), // Slightly rounded corners
                      ),
                      backgroundColor: MyColors
                          .bgColor, // Set background color to your custom color
                      insetPadding: const EdgeInsets.all(
                          10), // Reduce the outer padding to minimize white border
                      child: Container(
                        width: MediaQuery.of(context).size.width *
                            1.0, // Increased width to 90% of the screen
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: MyColors
                              .bgColor, // Background color of the dialog content
                          borderRadius: BorderRadius.circular(
                              8), // Ensure the inner content has rounded corners too
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize
                              .min, // Adjust height based on content
                          children: [
                            ReviewCard(review: review), // Review card
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  "Close",
                                  style: TextStyle(
                                      color: MyColors.selectedItemColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Card(
                color: MyColors.panelColor, // Set card background color
                child: ListTile(
                  title: Text(
                    notification
                        .message, // Use the message coming from JSON directly
                    style: TextStyle(
                      color: MyColors.textColor, // Set text color
                    ),
                  ),
                  // subtitle: notification.date != null
                  //     ? Align(
                  //         alignment: Alignment.bottomRight,
                  //         child: Text(
                  //           notification.date!, // Display date if available
                  //           style: TextStyle(
                  //             color: MyColors.textColor, // Set text color
                  //             fontSize: 12.0, // Smaller font size for date
                  //           ),
                  //         ),
                  //       )
                  //     : null,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
