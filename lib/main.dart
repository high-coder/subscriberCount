import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

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
  //String apiKey = "AIzaSyBbjIyOH0GsFy9NoyOdeiydpN8M4ZfLs9s";
  String apiKey = "AIzaSyAN2LMreWFxYO6XtlTKASmbk1dRe6LOOXI";
  String channelId = "UC4YI8YjlbPwNfQgsPysG-IA";
  getResponse() async {
    print("Entering here mate");
    String apiEndPoint =
        "https://www.googleapis.com/youtube/v3/channels?part=statistics&id=$channelId&key=$apiKey";
    var resp = await http.get(Uri.parse(apiEndPoint));
    var decodeResponse = jsonDecode(resp.body);
    print(decodeResponse);
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
    try {
      String endPoint2 =
          "https://www.googleapis.com/youtube/v3/channels?part=snippet&fields=items%2Fsnippet%2Fthumbnails%2Fdefault&id=$channelId&key=$apiKey";
      var resp = await http.get(Uri.parse(endPoint2));
      var decodeResponse = jsonDecode(resp.body);
      print(decodeResponse);
      channelImage =
          decodeResponse["items"][0]["snippet"]["thumbnails"]["default"]["url"];
      setState(() {});
      print(channelImage);
      print(decodeResponse);
    } catch (e) {
      print(e);
    }
  }

  int totalViews = 22000;
  void fetchChannelData() async {
    //totalViews = 0;
    String? nextPageToken;

    // Loop through pages of video data for the channel
    do {
      // Fetch video data for the channel with pageToken
      String? apiUrl;
      if (nextPageToken != null) {
        apiUrl =
            'https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=$channelId&type=video&key=$apiKey&pageToken=$nextPageToken';
      } else {
        apiUrl =
            'https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=$channelId&type=video&key=$apiKey';
        // apiUrl =
        //     'https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=$channelId&type=video&key=$apiKey';
      }
      DateTime currentDate = DateTime.now();
      DateTime ninetyDaysAgo = currentDate.subtract(Duration(days: 90));
      var response = await http.get(Uri.parse(apiUrl));
      //print(response.body);
      if (response.statusCode == 200) {
        // Parse the response JSON
        var data = jsonDecode(response.body);
        List<dynamic> items = data['items'];

        // Loop through each video and fetch view counts
        for (var item in items) {
          print("this is the item $item");
          String videoId = item['id']['videoId'];
          String date = item["snippet"]["publishedAt"];
          DateTime publishDate = DateTime.parse(date).toLocal();
          if (publishDate.isAfter(ninetyDaysAgo) &&
              publishDate.isBefore(currentDate)) {
            int viewCount = await fetchVideoViewCount(videoId);
            totalViews += viewCount;
            print("The date is within the last 90 days.");
          } else {
            print("The date is not within the last 90 days.");
          }
        }

        nextPageToken = data['nextPageToken'];
      } else {
        print(
            'Failed to fetch channel data. Status code: ${response.statusCode}');
        nextPageToken = null;
      }
    } while (nextPageToken != null);

    print('Total views in the last 90 days: $totalViews');
  }

  Future<int> fetchVideoViewCount(String videoId) async {
    String apiUrl =
        'https://www.googleapis.com/youtube/v3/videos?part=statistics&id=$videoId&key=$apiKey';
    var response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      int viewCount = int.parse(data['items'][0]['statistics']['viewCount']);
      return viewCount;
    } else {
      print(response.body);
      print(
          'Failed to fetch video view count. Status code: ${response.statusCode}');
      return 0;
    }
  }

  String? channelImage;
  late Timer _timer;
  String subCount = "0";
  @override
  void initState() {
    getChannelImage();
    getResponse();
    fetchChannelData();
    // TODO: implement initState
    super.initState();
    // _timer = Timer.periodic(Duration(seconds: 60), (timer) async {
    //   //print("this is that $timer");
    //   await getResponse();
    //   // if (temp != subCount)
    //   //   setState(() {
    //   //     subCount = temp;
    //   //   });
    //   // else {
    //   //   // do nothing
    //   //   print("no change in the subs");
    //   // }
    // });
  }

  /// Creating the ui for the same
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
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularPercentIndicator(
                    radius: 120.0,
                    lineWidth: 13.0,
                    animation: true,
                    percent: totalViews / 10000000,
                    center: Text(
                      "${(totalViews / 10000000) * 100}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.white),
                    ),
                    // footer: ,
                    circularStrokeCap: CircularStrokeCap.square,
                    progressColor: Colors.red,
                  ),
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
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    " ${10000000 - totalViews} views to Monetize",
                    style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0),
                  ),

                  SizedBox(
                    height: 80,
                  ),
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
