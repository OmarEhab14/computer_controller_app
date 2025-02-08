import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mouse_and_keyboard_remote_controller/models/connection_info.dart';

class PresentationRemote extends StatelessWidget {
  const PresentationRemote({super.key, required this.connectionInfo});
  final ConnectionInfo connectionInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
                    height: MediaQuery.of(context).size.height * 0.35,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[700]),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey[600]!,
                                  Colors.grey[900]!,
                                  Colors.grey[800]!
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              shape: BoxShape.circle),
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.black, Colors.grey[700]!],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                shape: BoxShape.circle),
                            child: IconButton(
                              onPressed: () {
                                connectionInfo.channel.sink.add('Presentation:next');
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.chevronRight,
                                size: 35,
                                color: Colors.grey[300],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          width: 80,
                          height: 80,
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
                              shape: BoxShape.circle),
                          padding: const EdgeInsets.all(2),
                          child: Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey[600]!,
                                    Colors.grey[700]!,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                shape: BoxShape.circle),
                            child: IconButton(
                              onPressed: () {
                                connectionInfo.channel.sink.add('Presentation:prev');
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.chevronLeft,
                                size: 20,
                                color: Colors.grey[300],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
  }
}