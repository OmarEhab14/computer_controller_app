import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mouse_and_keyboard_remote_controller/models/connection_info.dart';

class MediaController extends StatelessWidget {
  final ConnectionInfo connectionInfo;
  const MediaController({super.key, required this.connectionInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[700],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double size = constraints.maxHeight * 0.90; // Half of parent size

          return Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Center Play/Pause Button
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey[600]!,
                        Colors.black,
                        Colors.grey[400]!
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    height: size,
                    width: size,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey[600]!,
                              Colors.black,
                              Colors.grey[400]!
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          width: size * 0.58,
                          height: size * 0.58,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.grey[400]),
                          child: IconButton(
                            icon: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.play,
                                  size: size * 0.20,
                                  color: Colors.white,
                                ),
                                FaIcon(
                                  FontAwesomeIcons.pause,
                                  size: size * 0.20,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            onPressed: () {
                              connectionInfo.channel.sink.add('Media:play/pause');
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Volume Up (Top)
                Positioned(
                  top: 2,
                  left: 0,
                  right: 0,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: FaIcon(FontAwesomeIcons.plus,
                        size: size * 0.12, color: Colors.black),
                    onPressed: () {
                      connectionInfo.channel.sink.add('Media:volume_up');
                    },
                  ),
                ),

                // Volume Down (Bottom)
                Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: IconButton(
                    icon: FaIcon(FontAwesomeIcons.minus,
                        size: size * 0.12, color: Colors.black),
                    onPressed: () {
                      connectionInfo.channel.sink.add('Media:volume_down');
                    },
                  ),
                ),

                // Previous (Left)
                Positioned(
                  left: 1,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: FaIcon(FontAwesomeIcons.backward,
                        size: size * 0.1, color: Colors.black),
                    onPressed: () {
                      connectionInfo.channel.sink.add('Media:prev');
                    },
                  ),
                ),

                // Next (Right)
                Positioned(
                  right: 1,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: FaIcon(FontAwesomeIcons.forward,
                        size: size * 0.1, color: Colors.black),
                    onPressed: () {
                      connectionInfo.channel.sink.add('Media:next');
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
