import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//

export const onFollowUser = functions.firestore
  .document('/followers/{userId}/userFollowers/{followerId}')
  .onCreate(async (snapshot, context): Promise<void> => {
    console.log(snapshot.data());
    const userId = context.params.userId;
    const followerId = context.params.followerId;
    const followedUserPostsRef = admin
      .firestore()
      .collection('posts')
      .doc(userId)
      .collection('userPosts');
    const userFeedRef = admin
      .firestore()
      .collection('feeds')
      .doc(followerId)
      .collection('userFeed');
    const followedUserPostsSnapshot = await followedUserPostsRef.get();
    followedUserPostsSnapshot.forEach(doc => {
      if (doc.exists) {
        userFeedRef.doc(doc.id).set(doc.data());
      }
    });
  });

export const onUnfollowUser = functions.firestore
  .document('/followers/{userId}/userFollowers/{followerId}')
  .onDelete(async (snapshot, context): Promise<void> => {
    const userId = context.params.userId;
    const followerId = context.params.followerId;
    const userFeedRef = admin
      .firestore()
      .collection('feeds')
      .doc(followerId)
      .collection('userFeed')
      .where('authorId', '==', userId);
    const userPostsSnapshot = await userFeedRef.get();
    userPostsSnapshot.forEach(doc => {
      if (doc.exists) {
        doc.ref.delete();
      }
    });
  });

export const onUploadPost = functions.firestore
  .document('/posts/{userId}/userPosts/{postId}')
  .onCreate(async (snapshot, context): Promise<void> => {
    console.log(snapshot.data());
    const userId = context.params.userId;
    const postId = context.params.postId;
    const userFollowersRef = admin
      .firestore()
      .collection('followers')
      .doc(userId)
      .collection('userFollowers');
    const userFollowersSnapshot = await userFollowersRef.get();
    userFollowersSnapshot.forEach(doc => {
      admin
        .firestore()
        .collection('feeds')
        .doc(doc.id)
        .collection('userFeed')
        .doc(postId)
        .set(snapshot.data());
    });
  });

export const onUpdatePost = functions.firestore
  .document('/posts/{userId}/userPosts/{postId}')
  .onUpdate(async (snapshot, context): Promise<void> => {
    const userId = context.params.userId;
    const postId = context.params.postId;
    const newPostData = snapshot.after.data();
    console.log(newPostData);
    const userFollowersRef = admin
      .firestore()
      .collection('followers')
      .doc(userId)
      .collection('userFollowers');
    const userFollowersSnapshot = await userFollowersRef.get();
    userFollowersSnapshot.forEach(async userDoc => {
      const postRef = admin
        .firestore()
        .collection('feeds')
        .doc(userDoc.id)
        .collection('userFeed');
      const postDoc = await postRef.doc(postId).get();
      if (postDoc.exists) {
        postDoc.ref.update(newPostData);
      }
    });
  });

export const onDeletePost = functions.firestore
  .document('/posts/{userId}/userPosts/{postId}')
  .onDelete(async (snapshot, context): Promise<void> => {
    console.log(snapshot.data());
    const userId = context.params.userId;
    const postId = context.params.postId;
    const userFollowersRef = admin
      .firestore()
      .collection('followers')
      .doc(userId)
      .collection('userFollowers');
    const userFollowersSnapshot = await userFollowersRef.get();
    userFollowersSnapshot.forEach(doc => {
      admin
        .firestore()
        .collection('feeds')
        .doc(doc.id)
        .collection('userFeed')
        .doc(postId).delete();
      // 删除订阅者 feed 流的信息
    });
    admin.firestore().collection('comments').doc(postId).delete();
    // 删除该 post 的评论
    admin.firestore().collection('likes').doc(postId).delete();
    // 删除该 post 的赞
    const activitiesRef = admin.firestore().collection('activities').doc(userId).collection('userActivities');
    const activitiesSnapshot = await activitiesRef.get();
    activitiesSnapshot.forEach(doc => {
      const key = 'postId';
      if ( doc.data && String(doc.data[key]) === String(postId)) {
        activitiesRef.doc(doc.id).delete();
      }
    })
    // 删除该 post 的相关互动
  });

