import 'package:flutter/material.dart';
import 'package:cast/cast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bee_movies/shared/widget/detail_card_serie.dart';

class CastScreen extends StatefulWidget {
  final String videoUrl;
  final String name;
  final String imgUrl;
  const CastScreen({
    super.key,
    required this.videoUrl,
    required this.name,
    required this.imgUrl,
  });

  @override
  State<CastScreen> createState() => _CastScreenState();
}

class _CastScreenState extends State<CastScreen> {
  Future<List<CastDevice>>? _future;
  String? connectedDeviceName;
  CastSession? _currentSession;
  bool _mediaSent = false; // Para evitar múltiples envíos

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  void _requestLocationPermission() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      _startSearch();
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Se necesita permiso de ubicación para detectar dispositivos Cast.',
          ),
        ),
      );
    }
  }

  void _startSearch() {
    _future = CastDiscoveryService().search();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chromecast'),
        actions: [
          IconButton(
            icon: Icon(Icons.cast),
            onPressed: () async {
              if (connectedDeviceName != null) {
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder:
                      (_) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Conectado a $connectedDeviceName",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: Icon(Icons.cancel),
                              label: Text('Desconectar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () async {
                                try {
                                  await CastSessionManager().endSession(
                                    _currentSession!.sessionId,
                                  );
                                  setState(() {
                                    connectedDeviceName = null;
                                    _currentSession = null;
                                    _mediaSent = false;
                                  });
                                  // ignore: use_build_context_synchronously
                                  Navigator.pop(context); // Cierra el modal
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '🔌 Desconectado del dispositivo',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error al desconectar: $e'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("🔍 No hay ningún dispositivo conectado"),
                  ),
                );
              }
            },
          ),
        ],

        automaticallyImplyLeading: connectedDeviceName == null,
      ),
      body: Column(
        children: [
          if (connectedDeviceName != null)
            Expanded(child: Center(child: buildSerieCover(widget.imgUrl))),
          if (connectedDeviceName != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Reproduciendo en '$connectedDeviceName'",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

          if (connectedDeviceName == null)
            Expanded(
              child: FutureBuilder<List<CastDevice>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    );
                  }

                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Text('No se encontraron dispositivos Chromecast.'),
                    );
                  }

                  return ListView(
                    children:
                        snapshot.data!.map((device) {
                          return ListTile(
                            title: Text(device.name),
                            onTap: () => _connectAndPlayMedia(context, device),
                          );
                        }).toList(),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _connectAndPlayMedia(
    BuildContext context,
    CastDevice device,
  ) async {
    final session = await CastSessionManager().startSession(device);
    _currentSession = session;

    session.stateStream.listen((state) {
      if (state == CastSessionState.connected) {
        setState(() {
          connectedDeviceName = device.name;
        });

        ScaffoldMessenger.of(
          // ignore: use_build_context_synchronously
          context,
        ).showSnackBar(SnackBar(content: Text('✅ Conectado a ${device.name}')));
      }
    });

    session.messageStream.listen((message) {
      // print('🔁 Mensaje recibido: $message');

      if (message['type'] == 'RECEIVER_STATUS') {
        final applications = message['status']?['applications'];
        if (applications != null && applications.isNotEmpty) {
          final appId = applications.first['appId'];
          if (appId == 'CC1AD845') {
            Future.delayed(Duration(seconds: 1), () {
              _sendMessagePlayVideo(session);
            });
          }
        }
      }
    });

    session.sendMessage(CastSession.kNamespaceReceiver, {
      'type': 'LAUNCH',
      'appId': 'CC1AD845',
    });
  }

  void _sendMessagePlayVideo(CastSession session) {
    if (_mediaSent) return;
    _mediaSent = true;

    final media = {
      'contentId': widget.videoUrl,
      'contentType': 'video/mp4',
      'streamType': 'BUFFERED',
      'metadata': {
        'type': 0,
        'metadataType': 0,
        'title': widget.name,
        'images': [
          {'url': widget.imgUrl},
        ],
      },
    };

    session.sendMessage(CastSession.kNamespaceMedia, {
      'type': 'LOAD',
      'media': media,
      'autoplay': true,
      'currentTime': 0,
    });

    // print('🎬 Enviando video: ${widget.videoUrl}');
  }
}
