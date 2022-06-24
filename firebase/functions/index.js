const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();

exports.createChat = functions.https.onCall(async (data, context) => {
  const userId = data.userId;
  const myId = data.myId;
  const messageTime = data.time;
  const chatId = data.chatId

  admin.firestore().collection('messages').doc(chatId).set({"id": false});

  admin.firestore().collection('messages').doc(chatId).collection(chatId).doc(messageTime).set({
                                                                                                 "content": "Hello",
                                                                                                 "idFrom": myId,
                                                                                                 "idTo": userId,
                                                                                                 "timeStamp": messageTime
                                                                                                });
  return `${myId} + "-" + ${userId} + "  :  " + ${messageTime}`;
});