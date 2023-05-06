//import
const firestoreService = require("firestore-export-import");
const firebaseConfig = require("./config.js");
const serviceAccount = require("./serviceAccount.json");

// admin.initializeApp({
//     credential: admin.credential.cert(serviceAccount),
//     databaseUrl: firebaseConfig.databaseUrl,
// });

const jsonToFirestore = async () => {
    try {
        console.log("initialzing firebase");
        await firestoreService.initializeFirebaseApp(
            serviceAccount,
            serviceAccount.databaseUrl
        );

        await firestoreService.restore("./starbucks_All_menu.json");
    } catch (error) {
        console.log(error);
    }
};

jsonToFirestore();
