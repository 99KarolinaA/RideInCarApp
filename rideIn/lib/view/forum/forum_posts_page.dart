import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:icar/globalVariables.dart';
import 'package:icar/services/forum_service.dart';
import 'package:icar/utils/config.dart';
import 'package:icar/view/forum/components/forum_helper.dart';
import 'package:icar/view/forum/forum_post_details_page.dart';
import 'package:provider/provider.dart';

class ForumPostsPage extends StatelessWidget {
  final _forumRef = FirebaseFirestore.instance
      .collection("forum")
      .doc('posts')
      .collection('postContents')
      .orderBy('time', descending: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, title: Text('Forum')),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 20,
          ),
          child: StreamBuilder(
              stream: _forumRef.snapshots(),
              builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return Consumer<ForumService>(
                    builder: (context, provider, child) => Column(
                      children: [
                        for (int i = 0; i < snapshot.data.docs.length; i++)
                          // Card
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ForumPostDetailsPage(
                                          title: snapshot.data.docs[i]['title'],
                                          desc: snapshot.data.docs[i]['desc'],
                                          date: ForumService()
                                              .formatDate((snapshot.data.docs[i]
                                                      ['time'] as Timestamp)
                                                  .toDate())
                                              .toString(),
                                          category: snapshot.data.docs[i]
                                              ['category'],
                                          postImage: snapshot.data.docs[i]
                                              ['imageUrl'],
                                          postedBy: snapshot.data.docs[i]
                                              ['postedBy'],
                                          postId: snapshot
                                              .data.docs[i].reference.id,
                                        )),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 23),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: CachedNetworkImage(
                                        imageUrl: snapshot.data.docs[i]
                                            ['imageUrl'],
                                        placeholder: (context, url) {
                                          return Image.network(placeHolderUrl);
                                        },
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                    SizedBox(
                                      width: 20,
                                    ),
                                    //title and content
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            snapshot.data.docs[i]['title'],
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            snapshot.data.docs[i]['desc'],
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            ForumService()
                                                .formatDate((snapshot
                                                            .data.docs[i]
                                                        ['time'] as Timestamp)
                                                    .toDate())
                                                .toString(),
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    )
                                  ]),
                            ),
                          )
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error loading data');
                } else {
                  return CircularProgressIndicator();
                }
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Container(
          height: 60,
          width: 60,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.add),
        ),
        tooltip: 'Add post',
        onPressed: () {
          Provider.of<ForumService>(context, listen: false).setDefault();
          ForumHelper().showDialogForAddForumPost(context, userId);
        },
      ),
    );
  }
}
