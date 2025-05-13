import 'dart:io'; 

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'api/api_pexels.dart'; // File fungsi fetchVideos
import '../api/api_pexels.dart';
import '../model/video_item.dart';
import '../widget/video_player_widget.dart';

import 'login_page.dart';
import 'search_page.dart'; 

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MoodSocialApp());
}

class MoodSocialApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Support App',
      theme: ThemeData(useMaterial3: true, fontFamily: 'Chirp'),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // mendeteksi perubahan login
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          return HomePage(); // jika sudah login, masuk ke halaman utama
        } else {
          return LoginPage(); // jika belum login
        }
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    TweetPage(),
    Container(),
    NotificationPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UploadImagePage()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Color(0xFFFFFFFF),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: ""),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 104, 131, 179),
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(10),
              child: Icon(Icons.add, color: Colors.white),
            ),
            label: "",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 235, 235, 235),
      body: FutureBuilder<List<VideoItem>>(
        future: fetchVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            final videos = snapshot.data!;
            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: videos.length,
              itemBuilder: (context, index) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: VideoPlayerWidget(videoUrl: videos[index].url),
                );
              },
            );
          }
        },
      ),
    );
  }
}


class TweetPage extends StatefulWidget {
  @override
  _TweetPageState createState() => _TweetPageState();
}

class _TweetPageState extends State<TweetPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _posts = [];

  void _submitPost() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        _posts.insert(0, {
          "username": "Anonymous",
          "avatar": "assets/user1.png",
          "time": "baru saja",
          "content": _controller.text.trim(),
          "likes": 0,
          "comments": 0,
          "commentList": [],
        });
        _controller.clear();
      });
    }
  }

  void _likePost(int index) {
    setState(() {
      _posts[index]["likes"]++;
    });
  }

  void _commentPost(int index) {
    setState(() {
      _posts[index]["comments"]++;
      _posts[index]["commentList"].add("Komentar dari user lain...");
    });
  }

  Widget buildPost(Map<String, dynamic> post, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundImage: AssetImage(post["avatar"])),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post["username"],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(post["time"],
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(post["content"], style: TextStyle(fontSize: 15)),
            SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.favorite, color: Colors.red),
                  onPressed: () => _likePost(index),
                ),
                Text(post["likes"].toString()),
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.mode_comment_outlined,
                      color: Colors.grey[700]),
                  onPressed: () => _commentPost(index),
                ),
                Text(post["comments"].toString()),
              ],
            ),
            if (post["commentList"].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: post["commentList"]
                    .map<Widget>((comment) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Icon(Icons.person,
                                  size: 16, color: Colors.grey),
                              SizedBox(width: 6),
                              Expanded(child: Text(comment)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFC9D6E4),
      appBar: AppBar(
        title: Text(
          "Tweet / Curhat",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Curhatin aja di sini...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Color.fromARGB(255, 104, 131, 179),
                  ),
                  onPressed: _submitPost,
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            Expanded(
              child: _posts.isEmpty
                  ? Center(
                      child: Text(
                        "Belum ada curhatan",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        return buildPost(_posts[index], index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


class UploadImagePage extends StatefulWidget {
  @override
  _UploadImagePageState createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  File? _image;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFC9D6E4),
      appBar: AppBar(
        title: Text("Unggah Postingan", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.photo),
              label: Text("Pilih Gambar"),
            ),
            SizedBox(height: 20),
            _image != null
                ? Image.file(_image!, height: 300, fit: BoxFit.cover)
                : Text("Belum ada gambar yang dipilih"),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: "Tulis caption atau cerita kamu...",
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Postingan berhasil diunggah!")),
                );
              },
              child: Text("Unggah"),
            ),
          ],
        ),
      ),
    );
  }
}


class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> _images = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    try {
      final response = await http.get(
        Uri.parse('https://picsum.photos/v2/list?page=1&limit=30'),
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _images = data.map<Map<String, dynamic>>((item) {
            return {
              'url': 'https://picsum.photos/id/${item['id']}/400/400',
              'author': item['author'],
              'id': item['id'],
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching images: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE5EDF5),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SearchPage()),
                );
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.grey[600]!,
                    width: 0.8,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[600]),
                    SizedBox(width: 10),
                    Text(
                      "Search...",
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: _images.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  final image = _images[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailImagePage(
                            imageUrl: image['url'],
                            author: image['author'],
                            tag: 'img${image['id']}',
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'img${image['id']}',
                      child: Container(
                        color: Colors.grey[300],
                        child: Image.network(
                          image['url'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class DetailImagePage extends StatefulWidget {
  final String imageUrl;
  final String author;
  final String tag;

  const DetailImagePage({
    Key? key,
    required this.imageUrl,
    required this.author,
    required this.tag,
  }) : super(key: key);

  @override
  _DetailImagePageState createState() => _DetailImagePageState();
}

class _DetailImagePageState extends State<DetailImagePage> {
  bool isLiked = false;
  int likeCount = 97;

  @override
  Widget build(BuildContext context) {
    final String username = widget.author.toLowerCase().replaceAll(' ', '_');
    final String caption = "Self-care bukan egois, tapi bentuk cinta diri.";
    final String datePosted = '13 May';
    final String profileUrl = 'https://i.pravatar.cc/150?u=$username';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Explore", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header: user info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(profileUrl),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.author, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('@$username', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),

          // Image
          Hero(
            tag: widget.tag,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Image.network(
                widget.imageUrl,
                width: double.infinity,
                height: 350,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Action bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      isLiked = !isLiked;
                      likeCount += isLiked ? 1 : -1;
                    });
                  },
                ),
                SizedBox(width: 4),
                Icon(Icons.chat_bubble_outline, size: 24),
                SizedBox(width: 12),
                Icon(Icons.send, size: 24),
                Spacer(),
                Icon(Icons.bookmark_border, size: 24),
              ],
            ),
          ),

          // Like Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Liked by joyyyy_0905 and $likeCount others',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),

          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(text: widget.author, style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ' $caption'),
                ],
              ),
            ),
          ),

          // Date
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              datePosted,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),

          SizedBox(height: 16),
        ],
      ),
    );
  }
}


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  List<String> _imageUrls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> _pickProfileImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  Future<void> fetchImages() async {
    try {
      final response = await http.get(Uri.parse('https://picsum.photos/v2/list?page=1&limit=12'));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _imageUrls = data.map<String>((item) {
            final id = item['id'].toString();
            return 'https://picsum.photos/id/$id/300/300';
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching images: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Placeholder()), // Ganti dengan SettingsPage()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 235, 235, 235),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text("My Profile", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 8),
            Center(
              child: Stack(
                children: [
                  // Gradient Border
                  Container(
                    padding: EdgeInsets.all(3), // ketebalan border
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [ const Color.fromARGB(255, 139, 182, 255)!,  Colors.blueAccent!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : AssetImage('assets/images/profile.png') as ImageProvider,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        radius: 16,
                        child: Icon(Icons.add, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              "@budi_xmadu",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStat("1.2K", "Following"),
                _verticalDivider(),
                _buildStat("3.8K", "Follower"),
                _verticalDivider(),
                _buildStat("8.4K", "Like"),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // Log out logic here
                  },
                  child: Text("Logout 📤"),
                ),
              ],
            ),
            Divider(height: 30),

            // Grid Image Feed
            _isLoading
                ? CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      children: _imageUrls.map((url) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.broken_image),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String count, String label) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
      ],
    );
  }

  Widget _verticalDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text("•", style: TextStyle(fontSize: 18, color: Colors.grey[600])),
    );
  }
}


class SettingsPage extends StatelessWidget {
  void _logout(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFC9D6E4),
      appBar: AppBar(
        title: Text("Pengaturan", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Ubah Nama"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text("Ubah Kata Sandi"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text("Tentang Aplikasi"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Mood Support App',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 MoodSupport Team',
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
