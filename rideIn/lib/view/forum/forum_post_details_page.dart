import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:icar/functions.dart';
import 'package:icar/globalVariables.dart';
import 'package:icar/services/forum_service.dart';
import 'package:icar/utils/config.dart';
import 'package:icar/utils/custom_input.dart';
import 'package:icar/utils/others_helper.dart';

class ForumPostDetailsPage extends StatefulWidget {
  const ForumPostDetailsPage(
      {Key key,
      this.title,
      this.desc,
      this.date,
      this.category,
      this.postedBy,
      this.postImage,
      this.postId})
      : super(key: key);

  final title;
  final desc;
  final date;
  final postImage;
  final category;
  final postedBy;
  final postId;

  @override
  State<ForumPostDetailsPage> createState() => _ForumPostDetailsPageState();
}

class _ForumPostDetailsPageState extends State<ForumPostDetailsPage> {
  carMethods carObject = GetIt.instance.get<carMethods>();

  final commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _commentRef = FirebaseFirestore.instance
        .collection("forum")
        .doc('comments')
        .collection('commentsData')
        .where('postId', isEqualTo: widget.postId);

    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
                child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //image big preview
                    Container(
                      margin: const EdgeInsets.only(top: 30),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.withOpacity(.5))),
                      child: CachedNetworkImage(
                        imageUrl: widget.postImage,
                        placeholder: (context, url) {
                          return Image.network(placeHolderUrl);
                        },
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    Row(
                      children: [
                        //date
                        Text(
                          widget.date,
                          style: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 13),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 15,
                    ),

                    Text(
                      widget.title,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 15,
                    ),

                    // Description
                    Text(
                      widget.desc,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(
                      height: 15,
                    ),

                    //Comments
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comments',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),

                        //Commentor profile image and comment
                        StreamBuilder(
                            stream: _commentRef.snapshots(),
                            builder:
                                (_, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                  children: [
                                    for (int i = 0;
                                        i < snapshot.data.docs.length;
                                        i++)
                                      Container(
                                        padding: EdgeInsets.only(bottom: 13),
                                        margin: EdgeInsets.only(top: 20),
                                        decoration: BoxDecoration(
                                            border: Border(
                                          bottom: BorderSide(
                                            //                   <--- right side
                                            color: Colors.grey.withOpacity(.3),

                                            width: 0.5,
                                          ),
                                        )),
                                        child: Row(
                                          children: [
                                            FutureBuilder(
                                                future: carObject
                                                    .getCommentorDetails(
                                                        snapshot.data.docs[i]
                                                            ['commentedBy']),
                                                builder: (_, snap) {
                                                  if (snap.hasData) {
                                                    return CachedNetworkImage(
                                                      imageUrl: snap
                                                              .data['imgPro']
                                                              .isNotEmpty
                                                          ? snap.data['imgPro']
                                                          : userPlaceHolder,
                                                      placeholder:
                                                          (context, url) {
                                                        return Image.network(
                                                            placeHolderUrl);
                                                      },
                                                      height: 30,
                                                      width: 30,
                                                      fit: BoxFit.cover,
                                                    );
                                                  } else {
                                                    return Container();
                                                  }
                                                }),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Text(
                                              snapshot.data.docs[i]['comment'],
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                );
                              } else {
                                return OthersHelper().showLoading(Colors.blue);
                              }
                            }),
                      ],
                    )

                    //
                  ]),
            )),
          ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20),
            child: CustomInput(
              hintText: 'Write a comment',
              controller: commentController,
              onSubmit: (value) {
                if (value.isEmpty) return;

                Map<String, dynamic> commentData = {
                  'postId': widget.postId,
                  'commentedBy': userId,
                  'time': DateTime.now(),
                  'comment': value,
                };
                commentController.clear();
                carObject.addComment(commentData);
              },
              paddingHorizontal: 20,
            ),
          )
        ],
      ),
    );
  }
}
