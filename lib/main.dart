import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String apiKey = "AIzaSyDSVDavZvVtU3CF2Rr7KT7ZA_sYn4Ky64I";
  String channelId = "UC4YI8YjlbPwNfQgsPysG-IA";
  getResponse() async {
    print("Entering here mate");
    String apiEndPoint =
        "https://www.googleapis.com/youtube/v3/channels?part=statistics&id=$channelId&key=$apiKey";
    var resp = await http.get(Uri.parse(apiEndPoint));
    var decodeResponse = jsonDecode(resp.body);
    String newCount =
        decodeResponse['items'][0]['statistics']['subscriberCount'].toString();
    if (newCount != subCount) {
      setState(() {
        subCount = newCount;
      });
    }
    print(decodeResponse);
    print(newCount);
    return newCount;
  }

  getChannelImage() async {
    String endPoint2 =
        "https://www.googleapis.com/youtube/v3/channels?part=snippet&fields=items%2Fsnippet%2Fthumbnails%2Fdefault&id=$channelId&key=$apiKey";
    var resp = await http.get(Uri.parse(endPoint2));
    var decodeResponse = jsonDecode(resp.body);
    channelImage =
        decodeResponse["items"][0]["snippet"]["thumbnails"]["default"]["url"];
    setState(() {});
    print(channelImage);
    print(decodeResponse);
  }

  String? channelImage;
  late Timer _timer;
  String subCount = "0";
  @override
  void initState() {
    getChannelImage();
    getResponse();
    // TODO: implement initState
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 60), (timer) async {
      //print("this is that $timer");
      await getResponse();
      // if (temp != subCount)
      //   setState(() {
      //     subCount = temp;
      //   });
      // else {
      //   // do nothing
      //   print("no change in the subs");
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xff282828),
      body: SafeArea(
        child: Container(
            child: Stack(
          children: [
            Container(
              width: size.width,
              height: size.height / 4,
              decoration: BoxDecoration(color: Color(0xff1f1f1f)),
            ),
            Positioned(
              top: 10,
              child: Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Lottie.network(
                    //     "https://assets7.lottiefiles.com/packages/lf20_mtydannd.json"),
                    Lottie.asset("assets/dot.json"),
                    Text(
                      "Updating live",
                      style: GoogleFonts.openSans(
                          color: Colors.white, fontSize: 11),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              top: size.height / 4 - 50,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  channelImage != null
                      ? CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(channelImage!),
                        )
                      : CircleAvatar(
                          radius: 50,
                          //backgroundImage: NetworkImage(channelImage!),
                        ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Highcoder",
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            Container(),
            Positioned(
              bottom: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: size.width,
                  ),
                  // Align(
                  //   alignment: Alignment.topLeft,
                  //   child: Container(
                  //     padding: EdgeInsets.all(20),
                  //     child: Row(
                  //       children: [
                  //         Lottie.network(
                  //             "https://assets7.lottiefiles.com/packages/lf20_mtydannd.json"),
                  //         Text(
                  //           "Updating live",
                  //           style: GoogleFonts.openSans(
                  //               color: Colors.white, fontSize: 11),
                  //         )
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // Container(
                  //   width: 300,
                  //   height: 200,
                  //   child: Center(
                  //     child: Lottie.network(
                  //         "https://assets7.lottiefiles.com/packages/lf20_qe6rfoqh.json"),
                  //   ),
                  // ),
                  Text("$subCount",
                      style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.bold)),
                  Text(
                    "Subscribers",
                    style:
                        GoogleFonts.openSans(color: Colors.white, fontSize: 12),
                  )
                ],
              ),
            ),
          ],
        )),
      ),
    );
  }
}
