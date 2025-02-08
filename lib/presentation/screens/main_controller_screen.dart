import 'dart:async';
import 'dart:developer';
import 'dart:math' as Math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mouse_and_keyboard_remote_controller/constants/my_colors.dart';
import 'package:mouse_and_keyboard_remote_controller/constants/routes.dart';
import 'package:mouse_and_keyboard_remote_controller/cubit/connection_cubit.dart';
import 'package:mouse_and_keyboard_remote_controller/models/connection_info.dart';
import 'package:mouse_and_keyboard_remote_controller/presentation/widgets/keyboard_special_button.dart';
import 'package:mouse_and_keyboard_remote_controller/presentation/widgets/media_controller.dart';
import 'package:mouse_and_keyboard_remote_controller/presentation/widgets/mouse_button.dart';
import 'package:mouse_and_keyboard_remote_controller/presentation/widgets/presentation_remote.dart';

class MainControllerScreen extends StatefulWidget {
  final ConnectionInfo connectionInfo;

  MainControllerScreen({super.key, required this.connectionInfo});

  @override
  State<MainControllerScreen> createState() => _MainControllerScreenState();
}

class _MainControllerScreenState extends State<MainControllerScreen> {
  Offset? _lastPosition;
  DateTime? _lastTimeStamp;
  int _activeFingers = 0;
  bool _isDraggingTouchPad = false;
  bool _isRightClick = false;
  bool _isScrolling = false;
  double _scrollAccumulator = 0.0;
  double _horizontalScrollAccumulator = 0.0;
  bool _gestureInProgress = false;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();
  String _lastText = '';
  bool _presentationRemoteIsActive = false;
  bool _mediaControllerIsActive = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectionCubit, ConnectionCubitState>(
      listener: (context, state) {
        if (state is ConnectionDisconnected) {
          Navigator.pushReplacementNamed(context, connectionScreen);
        } else if (state is ConnectionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pushReplacementNamed(context, connectionScreen);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: const Text(
            'Mouse Controller',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.link_off),
              onPressed: () {
                BlocProvider.of<ConnectionCubit>(context).closeConnection();
              },
            ),
          ],
          elevation: 0,
          backgroundColor: MyColors.primaryColor,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Connected to: ${widget.connectionInfo.ip}:${widget.connectionInfo.port}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: RawGestureDetector(
                gestures: {
                  PanGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                      PanGestureRecognizer>(
                    () => PanGestureRecognizer(),
                    (PanGestureRecognizer instance) {
                      //Start
                      instance.onStart = (details) {
                        _lastPosition = details.localPosition;
                        _lastTimeStamp = DateTime.now();
                      };

                      //Update
                      instance.onUpdate = (details) {
                        if (_lastPosition != null) {
                          if (_activeFingers == 1) {
                            final DateTime currentTime = DateTime.now();
                            double deltaX =
                                (details.localPosition.dx - _lastPosition!.dx);
                            double deltaY =
                                (details.localPosition.dy - _lastPosition!.dy);

                            const double baseScale = 2.8;
                            final int timeElapsed = currentTime
                                .difference(_lastTimeStamp!)
                                .inMilliseconds
                                .clamp(0, 1000);
                            double velocityX = deltaX / timeElapsed;
                            double velocityY = deltaY / timeElapsed;

                            double velocityScalingFactor = baseScale +
                                (velocityX.abs() + velocityY.abs()) * 0.3;

                            if (deltaX.abs() < 1 && deltaY.abs() < 1) {
                              deltaX *= 1.5;
                              deltaY *= 1.5;
                            }

                            int scaledDeltaX =
                                (deltaX * velocityScalingFactor).isFinite
                                    ? (deltaX * velocityScalingFactor).toInt()
                                    : 0;
                            int scaledDeltaY =
                                (deltaY * velocityScalingFactor).isFinite
                                    ? (deltaY * velocityScalingFactor).toInt()
                                    : 0;

                            widget.connectionInfo.channel.sink
                                .add('move:$scaledDeltaX,$scaledDeltaY');

                            _lastPosition = details.localPosition;
                          } else if (_activeFingers == 2) {
                            _isScrolling = true;

                            double verticalScrollDelta =
                                details.delta.dy * 0.08;
                            double horizontalScrollDelta =
                                details.delta.dx * 0.08;
                            _scrollAccumulator += verticalScrollDelta;
                            _horizontalScrollAccumulator +=
                                horizontalScrollDelta;

                            log('acc = $_scrollAccumulator');
                            if (_scrollAccumulator.abs() > 0.01) {
                              widget.connectionInfo.channel.sink
                                  .add('Scroll:$_scrollAccumulator');
                              log('Sent scroll = $_scrollAccumulator');
                              _scrollAccumulator = 0.0;
                            }

                            if (_horizontalScrollAccumulator.abs() > 0.01) {
                              widget.connectionInfo.channel.sink
                                  .add('HScroll:$_horizontalScrollAccumulator');
                              _horizontalScrollAccumulator = 0.0;
                            }
                          } else if (_activeFingers == 3) {
                            if (_activeFingers == 3) {
                              double deltaY =
                                  details.localPosition.dy - _lastPosition!.dy;

                              if (deltaY.abs() > 20) {
                                if (deltaY < 0) {
                                  log("Three-finger swipe UP detected!");
                                  widget.connectionInfo.channel.sink
                                      .add('Swipe:up');
                                } else {
                                  log("Three-finger swipe DOWN detected!");
                                  widget.connectionInfo.channel.sink
                                      .add('Swipe:down');
                                }
                                _lastPosition = details.localPosition;
                              }
                            }
                          }

                          Future.delayed(const Duration(milliseconds: 16));
                        }
                      };
                      instance.onEnd = (details) {
                        _lastPosition = null;
                        _lastTimeStamp = null;
                        Future.delayed(const Duration(milliseconds: 350), () {
                          _isScrolling = false;
                        });
                        log('On pan end triggered!');
                        if (_isDraggingTouchPad && !_isRightClick) {
                          _isDraggingTouchPad = false;
                          widget.connectionInfo.channel.sink
                              .add('Release:left');
                        }
                      };
                      instance.onCancel = () {
                        _lastPosition = null;
                        _lastTimeStamp = null;
                        Future.delayed(const Duration(milliseconds: 350), () {
                          _isScrolling = false;
                        });
                        if (_isDraggingTouchPad && !_isRightClick) {
                          _isDraggingTouchPad = false;
                          log('On pan cancel triggered!!');
                          widget.connectionInfo.channel.sink
                              .add('Release:left');
                        }
                      };
                    },
                  ),
                  ScaleGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                      ScaleGestureRecognizer>(
                    () => ScaleGestureRecognizer(),
                    (ScaleGestureRecognizer instance) {
                      instance.onUpdate = (ScaleUpdateDetails details) {
                        if (_activeFingers == 2) {
                          double scaleChange = details.scale - 1.0;
                          if (scaleChange.abs() > 0.2) {
                            widget.connectionInfo.channel.sink
                                .add(scaleChange > 0 ? 'Zoom:in' : 'Zoom:out');
                          }
                        }
                      };
                    },
                  ),
                  TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                      TapGestureRecognizer>(
                    () => TapGestureRecognizer(),
                    (TapGestureRecognizer instance) {
                      instance.onTap = () {
                        if (_activeFingers == 0 &&
                            !_isRightClick &&
                            !_gestureInProgress) {
                          log('this is the problem');
                          widget.connectionInfo.channel.sink.add('Click:left');
                        }
                      };
                    },
                  ),
                  DoubleTapGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                          DoubleTapGestureRecognizer>(
                    () => DoubleTapGestureRecognizer(),
                    (DoubleTapGestureRecognizer instance) {
                      instance.onDoubleTapDown = (details) {
                        log('double tap down');
                        _isDraggingTouchPad = true;
                        widget.connectionInfo.channel.sink.add('Drag:left');
                      };
                      instance.onDoubleTap = () {
                        Timer(const Duration(milliseconds: 400), () {
                          if (!_isDraggingTouchPad) {
                            widget.connectionInfo.channel.sink
                                .add('Click:double_click');
                          }
                        });
                      };
                    },
                  ),
                  MultiTapGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                          MultiTapGestureRecognizer>(
                    () => MultiTapGestureRecognizer(),
                    (instance) {
                      instance.onTapDown =
                          (int pointer, TapDownDetails details) {
                        if (_gestureInProgress) {
                          return;
                        }

                        if (_activeFingers == 3) {
                          _gestureInProgress = true;
                          log('Triple fingers detected!');
                          widget.connectionInfo.channel.sink
                              .add('Click:triple_fingers');
                          Future.delayed(const Duration(milliseconds: 350), () {
                            _gestureInProgress = false;
                          });
                        } else if (_activeFingers == 2) {
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (!_isScrolling && !_gestureInProgress) {
                              _isRightClick = true;
                              log('right click yaay');
                              widget.connectionInfo.channel.sink
                                  .add('Click:right');
                            }
                          });

                          Future.delayed(const Duration(milliseconds: 400), () {
                            _isRightClick = false;
                          });
                        }
                      };
                    },
                  ),
                },
                child: Listener(
                  onPointerDown: (event) {
                    _activeFingers++;
                    log("Pointer down: $_activeFingers fingers");
                  },
                  onPointerUp: (event) {
                    _activeFingers--;
                    log("Pointer up: $_activeFingers fingers");
                  },
                  child: Container(
                    color: Colors.grey[800],
                    child: Center(
                      child: Text(
                        'Touch here to control the cursor',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox.shrink(
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (value) {
                  if (value is KeyDownEvent) {
                    if (value.logicalKey == LogicalKeyboardKey.backspace) {
                      _onKeyStroke(_textEditingController.text, true);
                    }
                  }
                },
                child: TextField(
                  onSubmitted: (value) {
                    widget.connectionInfo.channel.sink.add('SpecialKeyPress:enter');
                    widget.connectionInfo.channel.sink.add('SpecialKeyRelease:enter');
                    // Future.delayed(const Duration(milliseconds: 5000), () {
                      _focusNode.requestFocus();
                    // });
                  },
                  focusNode: _focusNode,
                  onChanged: (value) {
                    _onKeyStroke(value, false);
                  },
                  controller: _textEditingController,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 3,
                  // Left Button of the mouse
                  child: MouseButton(
                    // onTap: () {
                    //   widget.connectionInfo.channel.sink.add('Click:left');
                    //   log('tap from the button');
                    // },
                    onDoubleTap: () {
                      widget.connectionInfo.channel.sink
                          .add('Click:double_click');
                      log('double tap from the button');
                    },
                    onTapDown: (details) {
                      widget.connectionInfo.channel.sink.add('Drag:left');
                      log('left is dragging');
                    },
                    onTapUp: (details) {
                      widget.connectionInfo.channel.sink.add('Release:left');
                      log('left released on tap up!!');
                    },
                    onTapCancel: () {
                      widget.connectionInfo.channel.sink.add('Release:left');
                      log('left released on cancel!!');
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  // middle button of the mouse
                  child: MouseButton(
                    onTap: () {},
                    onDoubleTap: () {},
                    onTapDown: (details) {
                      widget.connectionInfo.channel.sink.add('Drag:middle');
                    },
                    onTapUp: (details) {
                      widget.connectionInfo.channel.sink.add('Release:middle');
                    },
                    onTapCancel: () {
                      widget.connectionInfo.channel.sink.add('Release:middle');
                    },
                  ),
                ),
                Expanded(
                  flex: 3,
                  // Right button of the mouse
                  child: MouseButton(
                    onTap: () {},
                    onDoubleTap: () {},
                    onTapDown: (details) {
                      widget.connectionInfo.channel.sink.add('Drag:right');
                    },
                    onTapUp: (details) {
                      widget.connectionInfo.channel.sink.add('Release:right');
                    },
                    onTapCancel: () {
                      widget.connectionInfo.channel.sink.add('Release:right');
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 55,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _focusNode.hasFocus
                      ? KeyboardSpecialButton(
                          child: const Text('caps lock'),
                          onTapDown: () {
                            widget.connectionInfo.channel.sink
                                .add('SpecialKeyPress:caps_lock');
                          },
                          onTapUp: () {
                            widget.connectionInfo.channel.sink
                                .add('SpecialKeyRelease:caps_lock');
                          },
                        )
                      : const SizedBox.shrink(),
                  KeyboardSpecialButton(
                    child: const Text('ctrl'),
                    onTapDown: () {
                      widget.connectionInfo.channel.sink
                          .add('SpecialKeyPress:ctrl');
                    },
                    onTapUp: () {
                      widget.connectionInfo.channel.sink
                          .add('SpecialKeyRelease:ctrl');
                    },
                  ),
                  KeyboardSpecialButton(
                    child: const FaIcon(
                      FontAwesomeIcons.windows,
                    ),
                    onTapDown: () {
                      widget.connectionInfo.channel.sink
                          .add('SpecialKeyPress:win');
                    },
                    onTapUp: () {
                      widget.connectionInfo.channel.sink
                          .add('SpecialKeyRelease:win');
                    },
                  ),
                  KeyboardSpecialButton(
                    onTap: _toggleKeyboard,
                    isFocused: _focusNode.hasFocus,
                    child: const FaIcon(
                      FontAwesomeIcons.keyboard,
                    ),
                  ),
                  _focusNode.hasFocus
                      ? _keyboardArrows()
                      : const SizedBox.shrink(),
                  KeyboardSpecialButton(
                    onTap: _togglePresentationRemote,
                    isFocused: _presentationRemoteIsActive,
                    child: const FaIcon(
                      FontAwesomeIcons.tv,
                    ),
                  ),
                  KeyboardSpecialButton(
                    onTap: _toggleMediaController,
                    isFocused: _mediaControllerIsActive,
                    child: const FaIcon(FontAwesomeIcons.music),
                  ),
                  KeyboardSpecialButton(
                    child: const Text('alt'),
                    onTapDown: () {
                      widget.connectionInfo.channel.sink
                          .add('SpecialKeyPress:alt');
                    },
                    onTapUp: () {
                      widget.connectionInfo.channel.sink
                          .add('SpecialKeyRelease:alt');
                    },
                  ),
                  KeyboardSpecialButton(
                    child: const Text('shift'),
                    onTapDown: () {
                      widget.connectionInfo.channel.sink
                          .add('SpecialKeyPress:shift');
                    },
                    onTapUp: () {
                      widget.connectionInfo.channel.sink
                          .add('SpecialKeyRelease:shift');
                    },
                  ),
                  KeyboardSpecialButton(
                    child: const Text('tab'),
                    onTap: () {
                      widget.connectionInfo.channel.sink
                          .add('SpecialKeyPress:tab');
                      widget.connectionInfo.channel.sink
                          .add('SpecialKeyRelease:tab');
                    },
                  ),
                  KeyboardSpecialButton(
                    child: const Text('copy'),
                    onTap: () {
                      widget.connectionInfo.channel.sink
                          .add('Abbreviation:copy');
                    },
                  ),
                  KeyboardSpecialButton(
                    child: const Text('paste'),
                    onTap: () {
                      widget.connectionInfo.channel.sink
                          .add('Abbreviation:paste');
                    },
                  ),
                  KeyboardSpecialButton(
                    child: const Text('ctrl+Z'),
                    onTap: () {
                      widget.connectionInfo.channel.sink
                          .add('Abbreviation:redo');
                    },
                  ),
                  KeyboardSpecialButton(
                    child: const Text('esc'),
                    onTap: () {
                      widget.connectionInfo.channel.sink
                          .add('SpecialKeyPress:esc');
                      widget.connectionInfo.channel.sink
                          .add('SpecialKeyRelease:esc');
                    },
                  ),
                ],
              ),
            ),
            _presentationRemoteIsActive
                ? PresentationRemote(connectionInfo: widget.connectionInfo)
                : const SizedBox.shrink(),
            _mediaControllerIsActive
                ? MediaController(connectionInfo: widget.connectionInfo)
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  void _toggleMediaController() {
    if (_mediaControllerIsActive) {
      setState(() {
        _mediaControllerIsActive = false;
      });
    } else {
      _focusNode.unfocus();
      setState(() {
        _presentationRemoteIsActive = false;
        _mediaControllerIsActive = true;
      });
    }
  }

  void _toggleKeyboard() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    } else {
      _presentationRemoteIsActive = false;
      _mediaControllerIsActive = false;
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  void _togglePresentationRemote() {
    if (_presentationRemoteIsActive) {
      setState(() {
        _presentationRemoteIsActive = false;
      });
    } else {
      _focusNode.unfocus();
      setState(() {
        _mediaControllerIsActive = false;
        _presentationRemoteIsActive = true;
      });
    }
  }

  void _onKeyStroke(String text, bool isDelete) {
    log(_lastText);
    log(text);
    if (isDelete) {
      widget.connectionInfo.channel.sink.add('KeyPress:delete');
    } else if (text.length == _lastText.length - 1) {
      widget.connectionInfo.channel.sink.add('KeyPress:delete');
    } else if (text.isNotEmpty) {
      String lastChar = text[text.length - 1];
      widget.connectionInfo.channel.sink.add('KeyPress:$lastChar');
    }
    _lastText = text;
  }

  Widget _keyboardArrows() {
    return Row(
      children: [
        KeyboardSpecialButton(
          child: const FaIcon(FontAwesomeIcons.caretLeft),
          onTap: () {
            widget.connectionInfo.channel.sink
                .add('SpecialKeyPress:arrow_left');
            widget.connectionInfo.channel.sink
                .add('SpecialKeyRelease:arrow_left');
          },
        ),
        Column(
          children: [
            KeyboardSpecialButton(
              child: const FaIcon(FontAwesomeIcons.caretUp),
              onTap: () {
                widget.connectionInfo.channel.sink
                    .add('SpecialKeyPress:arrow_up');
                widget.connectionInfo.channel.sink
                    .add('SpecialKeyRelease:arrow_up');
              },
            ),
            KeyboardSpecialButton(
              child: const FaIcon(FontAwesomeIcons.caretDown),
              onTap: () {
                widget.connectionInfo.channel.sink
                    .add('SpecialKeyPress:arrow_down');
                widget.connectionInfo.channel.sink
                    .add('SpecialKeyRelease:arrow_down');
              },
            ),
          ],
        ),
        KeyboardSpecialButton(
          child: const FaIcon(FontAwesomeIcons.caretRight),
          onTap: () {
            widget.connectionInfo.channel.sink
                .add('SpecialKeyPress:arrow_right');
            widget.connectionInfo.channel.sink
                .add('SpecialKeyRelease:arrow_right');
          },
        ),
      ],
    );
  }

  double _calculateDistance(Offset p1, Offset p2) {
    double distance = Math.sqrt(((p1.dx - p2.dx) * (p1.dx - p2.dx) +
        (p1.dy - p2.dy) * (p1.dy - p2.dy)));
    log('distance: $distance');
    return distance;
  }
}
