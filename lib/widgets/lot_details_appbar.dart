import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../config/colors.dart';

class LotDetailsAppBar extends StatefulWidget {
  final String image;
  final int lotId;

  const LotDetailsAppBar(
      {Key? key, required this.lotId, required this.image})
      : super(key: key);

  @override
  LotDetailsAppBarState createState() => LotDetailsAppBarState();

}

class LotDetailsAppBarState extends State<LotDetailsAppBar> {
  final user = FirebaseAuth.instance.currentUser!;

  Future<void> addToFavorites(String uid, int lot_id) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    String fid = const Uuid().v4();
    await _firestore.collection('favorites').doc(fid).set({
      'fid': fid,
      'uid': uid,
      'parkingLot': lot_id,
    });
  }

  Future<void> removeFromFavorites(String uid, int lot_id) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    var snapshot = await _firestore
        .collection("favorites")
        .where('uid', isEqualTo: uid)
        .where('parkingLot', isEqualTo: lot_id)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      systemOverlayStyle:
      const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      expandedHeight: 275.0,
      backgroundColor: Colors.white,
      elevation: 0.0,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          widget.image,
          fit: BoxFit.cover,
        ),
        stretchModes: const [
          StretchMode.blurBackground,
          StretchMode.zoomBackground,
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: Container(
          height: 32.0,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32.0),
              topRight: Radius.circular(32.0),
            ),
          ),
          child: Container(
            width: 40.0,
            height: 5.0,
            decoration: BoxDecoration(
              color: kOutlineColor,
              borderRadius: BorderRadius.circular(100.0),
            ),
          ),
        ),
      ),
      leadingWidth: 80.0,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 24.0, top: 7),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(56.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                height: 56.0,
                width: 56.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.20),
                ),
                child:
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("favorites")
                        .where('uid', isEqualTo: user.uid)
                        .where('parkingLot',
                        isEqualTo: widget.lotId)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot snapshot) {
                      if (snapshot.data == null) {
                        return Text("");
                      }
                      return IconButton(
                          icon: snapshot.data.docs.length == 0
                              ? const Icon(
                            Icons.star_border_outlined,
                            color: Colors.white,
                          )
                              : const Icon(
                            Icons.star,
                            color: Colors.yellow,
                          ),
                          onPressed: () => snapshot
                              .data.docs.length == 0
                              ? addToFavorites(
                              user.uid, widget.lotId)
                              : removeFromFavorites(
                              user.uid, widget.lotId));
                    }),
              ),
            ),
          ),
        ),
      ],
    );
  }

}

