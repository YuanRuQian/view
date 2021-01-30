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
        .doc(postId).delete().then((res) => {
          console.log(`删除 user ${doc.id} post ${postId} 的 feed 成功, res: ${JSON.stringify(res)}`);
        }).catch((err) => {
          console.log(`删除 user ${doc.id} post ${postId} 的 feed 失败, err: ${err}`);
        });;
      // 删除订阅者 feed 流的信息
    });
    const postCommentsRef = admin
      .firestore()
      .collection('comments')
      .doc(postId)
      .collection('postComments');
    const postCommentsSnapshot = await postCommentsRef.get();
    postCommentsSnapshot.forEach(doc => {
      admin.firestore().collection('comments').doc(postId).collection('postComments').doc(doc.id).delete().then((res) => {
        console.log(`删除 post ${postId} 评论 ${doc.id} 成功, res: ${JSON.stringify(res)}`);
      }).catch((err) => {
        console.log(`删除 post ${postId} 评论 ${doc.id} 失败, err: ${err}`);
      })
    })
    // 删除该 post 的评论
    const postLikesRef = admin.firestore().collection('likes').doc(postId).collection('postLikes');
    const postLikesSnapshot = await postLikesRef.get();
    postLikesSnapshot.forEach(doc => {
      admin.firestore().collection('likes').doc(postId).collection('postLikes').doc(doc.id).delete().then((res) => {
        console.log(`删除 post ${postId} 赞 ${doc.id} 成功, res: ${JSON.stringify(res)}`);
      }).catch((err) => {
        console.log(`删除 post ${postId} 赞 ${doc.id} 失败, err: ${err}`);
      })
    })
    // 删除该 post 的赞
    const activitiesRef = admin.firestore().collection('activities').doc(userId).collection('userActivities');
    const activitiesSnapshot = await activitiesRef.get();
    activitiesSnapshot.forEach(doc => {
      const key = 'postId';
      const data = doc.data();
      if ( data && data[key] === postId) {
        activitiesRef.doc(doc.id).delete().then((res) => {
          console.log(`删除 post ${postId} 的相关互动, 该用户的 doc post id 为 ${data[key]}, res: ${JSON.stringify(res)}`)
        }).catch((err) => {
          console.log(`删除 post ${postId} 的相关互动失败, err: ${err}`)
        });
      }
    })
    // 删除该 post 的相关互动
  });

