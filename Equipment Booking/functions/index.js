const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

admin.initializeApp();

exports.checkRentalDueDates = functions.pubsub.schedule("every 24 hours")
    .onRun(async (context) => {
      const db = admin.firestore();
      const now = new Date();
      const fortyEightHoursFromNow = new Date(
          now.getTime() +24 * 60 * 60 * 1000,
      );

      const rentalsSnapshot = await db
          .collection("rentals")
          .where("status", "==", "active")
          .get();

      const notifications = [];

      rentalsSnapshot.forEach((doc) => {
        const rental = doc.data();
        const returnDate = rental.return_date.toDate();

        if (returnDate > now && returnDate <= fortyEightHoursFromNow) {
          const itemNames = rental.items.map((item) => item.tool_id).join(", ");
          notifications.push({
            userId: rental.user_id,
            rentalId: rental.id,
            itemNames,
            returnDate: returnDate.toISOString(),
          });
        }
      });

      for (const notification of notifications) {
        const userDoc = await db.collection("users")
            .doc(notification.userId)
            .get();
        const fcmToken = userDoc.data()?.fcmToken;

        if (fcmToken) {
          const message = {
            token: fcmToken,
            notification: {
              title: "Rental Due Soon",
              body: `Your rental (${notification.itemNames}) is due on ${
                notification.returnDate
              }`,
            },
            data: {
              rentalId: notification.rentalId,
            },
          };

          await admin.messaging()
              .send(message)
              .then(() => {
                console.log(`Notification sent to ${notification.userId}`);
              })
              .catch((error) => {
                console.error("Error sending notification:", error);
              });
        }
      }

      return null;
    });
