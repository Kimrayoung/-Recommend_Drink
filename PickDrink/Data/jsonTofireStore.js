// import 저장된 파일 불러오기 node 환경이기 때문에 require 사용
const firestoreService = require("firestore-export-import");
const firebaseConfig = require("./config.js");
const serviceAccount = require("./serviceAccount.json");

//  JSON to firestore
const jsonToFirestore = async () => {
    try {
        console.log("init firebase");
        // firestore 초기화 시작
        await firestoreService.initializeFirebaseApp(
            serviceAccount,
            firebaseConfig.databaseURL
        );
        console.log("firebase initialized ");

        // data.json 파일 firestore 에 push
        await firestoreService.restore("./menu_example.json");
        console.log("upload success");
    } catch (error) {
        console.log(error);
    }
};

// 함수 실행
jsonToFirestore();
