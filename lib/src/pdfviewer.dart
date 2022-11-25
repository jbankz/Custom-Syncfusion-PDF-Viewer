import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_core/localizations.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'bookmark/bookmark_view.dart';
import 'common/pdf_provider.dart';
import 'common/pdfviewer_helper.dart';
import 'common/pdfviewer_plugin.dart';
import 'control/enums.dart';
import 'control/pagination.dart';
import 'control/pdf_page_view.dart';
import 'control/pdf_scrollable.dart';
import 'control/pdftextline.dart';
import 'control/pdfviewer_callback_details.dart';
import 'control/single_page_view.dart';

typedef PdfTextSelectionChangedCallback = void Function(
    PdfTextSelectionChangedDetails details);

typedef CustomBookmarkBuilder = Widget Function(BookmarkView bookmarkView);

typedef PdfHyperlinkClickedCallback = void Function(
    PdfHyperlinkClickedDetails details);

typedef PdfDocumentLoadedCallback = void Function(
    PdfDocumentLoadedDetails details);

typedef PdfDocumentLoadFailedCallback = void Function(
    PdfDocumentLoadFailedDetails details);

typedef PdfZoomLevelChangedCallback = void Function(PdfZoomDetails details);

typedef PdfPageChangedCallback = void Function(PdfPageChangedDetails details);

typedef _PdfControllerListener = void Function({String? property});

@immutable
class SfPdfViewer extends StatefulWidget {
  SfPdfViewer.asset(String name,
      {Key? key,
      AssetBundle? bundle,
      this.canShowScrollHead = true,
      this.pageSpacing = 4,
      this.controller,
      this.onZoomLevelChanged,
      this.canShowScrollStatus = true,
      this.onPageChanged,
      this.onDocumentLoaded,
      this.enableDoubleTapZooming = true,
      this.enableTextSelection = true,
      this.onTextSelectionChanged,
      this.onHyperlinkClicked,
      this.onDocumentLoadFailed,
      this.enableDocumentLinkAnnotation = true,
      this.canShowPaginationDialog = true,
      this.initialScrollOffset = Offset.zero,
      this.initialZoomLevel = 1,
      this.interactionMode = PdfInteractionMode.selection,
      this.scrollDirection = PdfScrollDirection.vertical,
      this.pageLayoutMode = PdfPageLayoutMode.continuous,
      this.currentSearchTextHighlightColor =
          const Color.fromARGB(80, 249, 125, 0),
      this.otherSearchTextHighlightColor =
          const Color.fromARGB(50, 255, 255, 1),
      this.password,
      this.canShowPasswordDialog = true,
      this.canShowHyperlinkDialog = true,
      this.enableHyperlinkNavigation = true,
      this.showContents = true,
      this.customBookmarkBuilder,
      this.sfPdfViewerThemeData,
      this.themeData})
      : _provider = AssetPdf(name, bundle),
        assert(pageSpacing >= 0),
        super(key: key);

  SfPdfViewer.network(String src,
      {Key? key,
      Map<String, String>? headers,
      this.canShowScrollHead = true,
      this.pageSpacing = 4,
      this.controller,
      this.onZoomLevelChanged,
      this.canShowScrollStatus = true,
      this.onPageChanged,
      this.enableDoubleTapZooming = true,
      this.enableTextSelection = true,
      this.onTextSelectionChanged,
      this.onHyperlinkClicked,
      this.onDocumentLoaded,
      this.onDocumentLoadFailed,
      this.enableDocumentLinkAnnotation = true,
      this.canShowPaginationDialog = true,
      this.initialScrollOffset = Offset.zero,
      this.initialZoomLevel = 1,
      this.interactionMode = PdfInteractionMode.selection,
      this.scrollDirection = PdfScrollDirection.vertical,
      this.pageLayoutMode = PdfPageLayoutMode.continuous,
      this.currentSearchTextHighlightColor =
          const Color.fromARGB(80, 249, 125, 0),
      this.otherSearchTextHighlightColor =
          const Color.fromARGB(50, 255, 255, 1),
      this.password,
      this.canShowPasswordDialog = true,
      this.canShowHyperlinkDialog = true,
      this.enableHyperlinkNavigation = true,
      this.showContents = true,
      this.customBookmarkBuilder,
      this.sfPdfViewerThemeData,
      this.themeData})
      : _provider = NetworkPdf(src, headers),
        assert(pageSpacing >= 0),
        super(key: key);

  SfPdfViewer.memory(Uint8List bytes,
      {Key? key,
      this.canShowScrollHead = true,
      this.pageSpacing = 4,
      this.controller,
      this.onZoomLevelChanged,
      this.canShowScrollStatus = true,
      this.onPageChanged,
      this.enableDoubleTapZooming = true,
      this.enableTextSelection = true,
      this.onTextSelectionChanged,
      this.onHyperlinkClicked,
      this.onDocumentLoaded,
      this.onDocumentLoadFailed,
      this.enableDocumentLinkAnnotation = true,
      this.canShowPaginationDialog = true,
      this.initialScrollOffset = Offset.zero,
      this.initialZoomLevel = 1,
      this.interactionMode = PdfInteractionMode.selection,
      this.scrollDirection = PdfScrollDirection.vertical,
      this.pageLayoutMode = PdfPageLayoutMode.continuous,
      this.currentSearchTextHighlightColor =
          const Color.fromARGB(80, 249, 125, 0),
      this.otherSearchTextHighlightColor =
          const Color.fromARGB(50, 255, 255, 1),
      this.password,
      this.canShowPasswordDialog = true,
      this.canShowHyperlinkDialog = true,
      this.enableHyperlinkNavigation = true,
      this.showContents = true,
      this.customBookmarkBuilder,
      this.sfPdfViewerThemeData,
      this.themeData})
      : _provider = MemoryPdf(bytes),
        assert(pageSpacing >= 0),
        super(key: key);

  SfPdfViewer.file(File file,
      {Key? key,
      this.canShowScrollHead = true,
      this.pageSpacing = 4,
      this.controller,
      this.onZoomLevelChanged,
      this.canShowScrollStatus = true,
      this.onPageChanged,
      this.enableDoubleTapZooming = true,
      this.enableTextSelection = true,
      this.onTextSelectionChanged,
      this.onHyperlinkClicked,
      this.onDocumentLoaded,
      this.onDocumentLoadFailed,
      this.enableDocumentLinkAnnotation = true,
      this.canShowPaginationDialog = true,
      this.initialScrollOffset = Offset.zero,
      this.initialZoomLevel = 1,
      this.interactionMode = PdfInteractionMode.selection,
      this.scrollDirection = PdfScrollDirection.vertical,
      this.pageLayoutMode = PdfPageLayoutMode.continuous,
      this.currentSearchTextHighlightColor =
          const Color.fromARGB(80, 249, 125, 0),
      this.otherSearchTextHighlightColor =
          const Color.fromARGB(50, 255, 255, 1),
      this.password,
      this.canShowPasswordDialog = true,
      this.canShowHyperlinkDialog = true,
      this.enableHyperlinkNavigation = true,
      this.showContents = true,
      this.customBookmarkBuilder,
      this.sfPdfViewerThemeData,
      this.themeData})
      : _provider = FilePdf(file),
        assert(pageSpacing >= 0),
        super(key: key);

  final PdfProvider _provider;

  final PdfInteractionMode interactionMode;

  final double initialZoomLevel;

  final Offset initialScrollOffset;

  final bool enableDocumentLinkAnnotation;

  final double pageSpacing;

  final PdfViewerController? controller;

  final bool canShowScrollHead;

  final bool canShowScrollStatus;

  final bool canShowPaginationDialog;

  final bool enableDoubleTapZooming;

  final bool enableTextSelection;

  final Color currentSearchTextHighlightColor;

  final Color otherSearchTextHighlightColor;

  final PdfDocumentLoadedCallback? onDocumentLoaded;

  final PdfDocumentLoadFailedCallback? onDocumentLoadFailed;

  final PdfZoomLevelChangedCallback? onZoomLevelChanged;

  final PdfTextSelectionChangedCallback? onTextSelectionChanged;

  final PdfHyperlinkClickedCallback? onHyperlinkClicked;

  final PdfPageChangedCallback? onPageChanged;

  final CustomBookmarkBuilder? customBookmarkBuilder;

  final PdfScrollDirection scrollDirection;

  final PdfPageLayoutMode pageLayoutMode;

  final String? password;

  final bool canShowPasswordDialog;

  final bool canShowHyperlinkDialog;

  final bool enableHyperlinkNavigation;

  final bool showContents;

  final SfPdfViewerThemeData? sfPdfViewerThemeData;
  final ThemeData? themeData;

  @override
  SfPdfViewerState createState() => SfPdfViewerState();
}

class SfPdfViewerState extends State<SfPdfViewer> with WidgetsBindingObserver {
  late PdfViewerPlugin _plugin;
  late PdfViewerController _pdfViewerController;
  CancelableOperation<Uint8List>? _getPdfFileCancellableOperation;
  CancelableOperation<PdfDocument?>? _pdfDocumentLoadCancellableOperation;
  CancelableOperation<List<dynamic>?>? _getHeightCancellableOperation,
      _getWidthCancellableOperation;
  List<dynamic>? _originalHeight;
  List<dynamic>? _originalWidth;
  double? _viewportHeightInLandscape;
  double? _otherContextHeight;
  double _maxPdfPageWidth = 0.0;
  final double _minScale = 1;
  final double _maxScale = 3;
  bool _isScaleEnabled = !kIsDesktop;
  bool _isPdfPageTapped = false;
  bool _isDocumentLoadInitiated = false;
  Orientation? _deviceOrientation;
  double _viewportWidth = 0.0;
  Offset _offsetBeforeOrientationChange = Offset.zero;
  late BoxConstraints _viewportConstraints;
  int _previousPageNumber = 0;
  PdfDocument? _document;
  bool _hasError = false;
  bool _panEnabled = true;
  bool _isMobile = false;
  bool _isSearchStarted = false;
  bool _isKeyPadRaised = false;
  bool _isTextSelectionCleared = false;
  final Map<int, PdfPageInfo> _pdfPages = <int, PdfPageInfo>{};
  final GlobalKey _childKey = GlobalKey();
  final GlobalKey<SinglePageViewState> _singlePageViewKey = GlobalKey();
  final GlobalKey<BookmarkViewControllerState> _bookmarkKey = GlobalKey();
  final GlobalKey<PdfScrollableState> _pdfScrollableStateKey = GlobalKey();
  final Map<int, GlobalKey<PdfPageViewState>> _pdfPagesKey =
      <int, GlobalKey<PdfPageViewState>>{};
  SystemMouseCursor _cursor = SystemMouseCursors.basic;
  List<MatchedItem>? _textCollection = <MatchedItem>[];
  PdfTextExtractor? _pdfTextExtractor;
  double _maxScrollExtent = 0;
  Size _pdfDimension = Size.zero;
  bool _isPageChanged = false;
  bool _isSinglePageViewPageChanged = false;
  bool _isOverflowed = false;
  bool _isZoomChanged = false;
  int _startPage = 0, _endPage = 0, _bufferCount = 0;
  final List<int> _renderedImages = <int>[];
  final Map<int, String> _pageTextExtractor = <int, String>{};
  Size _totalImageSize = Size.zero;
  late PdfScrollDirection _scrollDirection;
  late PdfScrollDirection _tempScrollDirection;
  late PdfPageLayoutMode _pageLayoutMode;
  double _pageOffsetBeforeScrollDirectionChange = 0.0;
  Size _pageSizeBeforeScrollDirectionChange = Size.zero;
  Offset _scrollDirectionSwitchOffset = Offset.zero;
  bool _isScrollDirectionChange = false;
  PageController _pageController = PageController();
  double _previousHorizontalOffset = 0.0;
  double _viewportHeight = 0.0;
  bool _iskeypadClosed = false;
  Offset _layoutChangeOffset = Offset.zero;
  int _previousSinglePage = 1;
  late Uint8List _pdfBytes;
  late Uint8List _decryptedBytes;
  bool _passwordVisible = true;
  bool _isEncrypted = false;
  final TextEditingController _textFieldController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();
  bool _errorTextPresent = false;
  SfLocalizations? _localizations;
  bool _isEncryptedDocument = false;
  bool _visibility = false;
  bool _isPasswordUsed = false;
  double _previousTiledZoomLevel = 1;
  TextDirection _textDirection = TextDirection.ltr;
  bool _isOrientationChanged = false;
  bool _isTextExtractionCompleted = false;
  final List<int> _matchedTextPageIndices = <int>[];
  final Map<int, String> _extractedTextCollection = <int, String>{};
  Isolate? _textSearchIsolate;
  Isolate? _textExtractionIsolate;

  SfPdfViewerThemeData? _pdfViewerThemeData;

  ThemeData? _themeData;

  bool get isBookmarkViewOpen =>
      _bookmarkKey.currentState?.showBookmark ?? false;

  @override
  void initState() {
    super.initState();
    _plugin = PdfViewerPlugin();
    _scrollDirection = widget.pageLayoutMode == PdfPageLayoutMode.single
        ? PdfScrollDirection.horizontal
        : widget.scrollDirection;
    _tempScrollDirection = _scrollDirection;
    _pageLayoutMode = widget.pageLayoutMode;
    _pdfViewerController = widget.controller ?? PdfViewerController();
    _pdfViewerController._addListener(_handleControllerValueChange);
    _setInitialScrollOffset();
    _offsetBeforeOrientationChange = Offset.zero;
    _hasError = false;
    _panEnabled = true;
    _isTextSelectionCleared = false;
    _loadPdfDocument(false);
    _previousPageNumber = 1;
    _maxPdfPageWidth = 0;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pdfViewerThemeData =
        widget.sfPdfViewerThemeData ?? SfPdfViewerTheme.of(context);
    _themeData = widget.themeData ?? Theme.of(context);
    _localizations = SfLocalizations.of(context);
    _isOrientationChanged = _deviceOrientation != null &&
        _deviceOrientation != MediaQuery.of(context).orientation;
  }

  @override
  void didUpdateWidget(SfPdfViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller == null) {
      if (widget.controller != null) {
        _pdfViewerController._removeListener(_handleControllerValueChange);
        _pdfViewerController._reset();
        _pdfViewerController = widget.controller!;
        _pdfViewerController._addListener(_handleControllerValueChange);
      }
    } else {
      if (widget.controller == null) {
        _pdfViewerController._removeListener(_handleControllerValueChange);
        _pdfViewerController = PdfViewerController();
        _pdfViewerController._addListener(_handleControllerValueChange);
      } else if (widget.controller != oldWidget.controller) {
        _pdfViewerController._removeListener(_handleControllerValueChange);
        _pdfViewerController = widget.controller!;
        _pdfViewerController._addListener(_handleControllerValueChange);
      }
    }
    _scrollDirection = widget.pageLayoutMode == PdfPageLayoutMode.single
        ? PdfScrollDirection.horizontal
        : widget.scrollDirection;
    _compareDocument(oldWidget._provider.getPdfBytes(context),
        widget._provider.getPdfBytes(context), oldWidget.password);
    if (oldWidget.pageLayoutMode != widget.pageLayoutMode &&
        oldWidget.controller != null) {
      _updateOffsetOnLayoutChange(oldWidget.controller!.zoomLevel,
          oldWidget.controller!.scrollOffset, oldWidget.pageLayoutMode);
    }
  }

  void _setInitialScrollOffset() {
    if (widget.key is PageStorageKey && PageStorage.of(context) != null) {
      final dynamic offset = PageStorage.of(context)!.readState(context);
      _pdfViewerController._verticalOffset = offset.dy as double;
      _pdfViewerController._horizontalOffset = offset.dx as double;
      final dynamic zoomLevel = PageStorage.of(context)
          ?.readState(context, identifier: 'zoomLevel_${widget.key}');

      _pdfViewerController.zoomLevel = zoomLevel as double;
    } else {
      _pdfViewerController._verticalOffset = widget.initialScrollOffset.dy;
      _pdfViewerController._horizontalOffset = widget.initialScrollOffset.dx;
    }
    _isDocumentLoadInitiated = false;
  }

  Future<void> _compareDocument(Future<Uint8List> oldBytesData,
      Future<Uint8List> newBytesData, String? oldPassword) async {
    final Uint8List oldBytes = await oldBytesData;
    final Uint8List newBytes = await newBytesData;
    if (!listEquals(oldBytes, newBytes) ||
        (widget.password != null && widget.password != oldPassword)) {
      _pdfViewerController.clearSelection();

      await _loadPdfDocument(true);
    }
  }

  @override
  void dispose() {
    _getPdfFileCancellableOperation?.cancel();
    _pdfDocumentLoadCancellableOperation?.cancel();
    _getHeightCancellableOperation?.cancel();
    _getWidthCancellableOperation?.cancel();
    _matchedTextPageIndices.clear();
    _extractedTextCollection.clear();
    _pdfViewerThemeData = null;
    _localizations = null;
    imageCache.clear();
    _killTextSearchIsolate();
    _plugin.closeDocument();
    _killTextExtractionIsolate();
    _disposeCollection(_originalHeight);
    _disposeCollection(_originalWidth);
    _renderedImages.clear();
    _pageTextExtractor.clear();
    _pdfPages.clear();
    _pdfPagesKey.clear();
    _focusNode.dispose();
    _document?.dispose();
    _document = null;
    _pdfPagesKey[_pdfViewerController.pageNumber]
        ?.currentState
        ?.canvasRenderBox
        ?.disposeSelection();
    if (widget.onTextSelectionChanged != null) {
      widget
          .onTextSelectionChanged!(PdfTextSelectionChangedDetails(null, null));
    }
    _pdfViewerController._removeListener(_handleControllerValueChange);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _disposeCollection(List<dynamic>? list) {
    if (list != null) {
      list = null;
    }
  }

  void _reset() {
    _pdfPagesKey[_pdfViewerController.pageNumber]
        ?.currentState
        ?.canvasRenderBox
        ?.disposeMouseSelection();
    _isTextSelectionCleared = false;
    _killTextExtractionIsolate();
    _killTextSearchIsolate();
    _isEncrypted = false;
    _matchedTextPageIndices.clear();
    _extractedTextCollection.clear();
    _isTextExtractionCompleted = false;
    _errorTextPresent = false;
    _passwordVisible = true;
    _isEncryptedDocument = false;
    _pdfScrollableStateKey.currentState?.reset();
    _offsetBeforeOrientationChange = Offset.zero;
    _previousPageNumber = 1;
    _pdfViewerController._reset();
    _pdfPages.clear();
    _plugin.closeDocument();
    _pageTextExtractor.clear();
    _document?.dispose();
    _document = null;
    imageCache.clear();
    _startPage = 0;
    _endPage = 0;
    _bufferCount = 0;
    _renderedImages.clear();
    _hasError = false;
    _isDocumentLoadInitiated = false;
    _pdfPagesKey.clear();
    _maxPdfPageWidth = 0;
    _maxScrollExtent = 0;
    _pdfDimension = Size.zero;
    _isPageChanged = false;
    _isSinglePageViewPageChanged = false;
    _isPasswordUsed = false;
  }

  Future<void> _loadPdfDocument(bool isPdfChanged) async {
    try {
      if (!_isEncrypted) {
        _getPdfFileCancellableOperation =
            CancelableOperation<Uint8List>.fromFuture(
          widget._provider.getPdfBytes(context),
        );
      }
      _pdfBytes = _isEncrypted
          ? _decryptedBytes
          : (await _getPdfFileCancellableOperation?.value)!;
      if (isPdfChanged) {
        _reset();
        _plugin = PdfViewerPlugin();
        _checkMount();
      }
      _pdfDocumentLoadCancellableOperation =
          CancelableOperation<PdfDocument?>.fromFuture(_getPdfFile(_pdfBytes));
      _document = await _pdfDocumentLoadCancellableOperation?.value;
      if (_document != null) {
        _pdfTextExtractor = PdfTextExtractor(_document!);
        if (!kIsWeb) {
          _performTextExtraction();
        }
      }
      final int pageCount = await _plugin.initializePdfRenderer(_pdfBytes);
      _pdfViewerController._pageCount = pageCount;
      if (pageCount > 0) {
        _pdfViewerController._pageNumber = 1;
      }
      _pdfViewerController.zoomLevel = widget.initialZoomLevel;
      _setInitialScrollOffset();
      if (_document != null && widget.onDocumentLoaded != null) {
        _isDocumentLoadInitiated = false;
        widget.onDocumentLoaded!(PdfDocumentLoadedDetails(_document!));
      }
      _getHeightCancellableOperation =
          CancelableOperation<List<dynamic>?>.fromFuture(
              _plugin.getPagesHeight());
      _originalHeight = await _getHeightCancellableOperation?.value;
      _getWidthCancellableOperation =
          CancelableOperation<List<dynamic>?>.fromFuture(
              _plugin.getPagesWidth());
      _originalWidth = await _getWidthCancellableOperation?.value;
    } catch (e) {
      _pdfViewerController._reset();
      _hasError = true;
      _killTextExtractionIsolate();
      final String errorMessage = e.toString();
      if (errorMessage.contains('Invalid cross reference table') ||
          errorMessage.contains('FormatException: Invalid radix-10 number') ||
          errorMessage.contains('RangeError (index): Index out of range') ||
          errorMessage.contains(
              'RangeError (end): Invalid value: Not in inclusive range')) {
        if (widget.onDocumentLoadFailed != null) {
          widget.onDocumentLoadFailed!(PdfDocumentLoadFailedDetails(
              'Format Error',
              'This document cannot be opened because it is corrupted or not a PDF.'));
        }
      } else if (errorMessage.contains('Cannot open an encrypted document.')) {
        if (!_isPasswordUsed) {
          try {
            _decryptedProtectedDocument(_pdfBytes, widget.password);
            _isPasswordUsed = true;
          } catch (e) {
            if (widget.onDocumentLoadFailed != null) {
              if (widget.password == '' || widget.password == null) {
                widget.onDocumentLoadFailed!(PdfDocumentLoadFailedDetails(
                    'Empty Password Error',
                    'The provided `password` property is empty so unable to load the encrypted document.'));
              } else {
                widget.onDocumentLoadFailed!(PdfDocumentLoadFailedDetails(
                    'Invalid Password Error',
                    'The provided `password` property is invalid so unable to load the encrypted document.'));
              }
            }
          }
        }
        if (widget.canShowPasswordDialog && !_isPasswordUsed) {
          if (_isMobile) {
            _checkMount();
            _showPasswordDialog();
          } else {
            _isEncryptedDocument = true;
            _visibility = true;
            _checkMount();
          }
        }
      } else if (errorMessage.contains('Unable to load asset') ||
          (errorMessage.contains('FileSystemException: Cannot open file'))) {
        if (widget.onDocumentLoadFailed != null) {
          widget.onDocumentLoadFailed!(PdfDocumentLoadFailedDetails(
              'File Not Found',
              'The document cannot be opened because the provided path or link is invalid.'));
        }
      } else {
        if (widget.onDocumentLoadFailed != null) {
          widget.onDocumentLoadFailed!(PdfDocumentLoadFailedDetails(
              'Error', 'There was an error opening this document.'));
        }
      }
    } finally {
      _checkMount();
    }
  }

  Future<void> _performTextExtraction() async {
    final ReceivePort receivePort = ReceivePort();
    receivePort.listen((dynamic message) {
      if (message is SendPort) {
        message.send(<dynamic>[
          receivePort.sendPort,
          _pdfTextExtractor,
          _document?.pages.count,
        ]);
      } else if (message is Map<int, String>) {
        _extractedTextCollection.addAll(message);
        _isTextExtractionCompleted = true;
        if (_pdfViewerController._searchText.isNotEmpty) {
          _pdfViewerController._notifyPropertyChangedListeners(
              property: 'searchText');
        }
      }
    });
    _textExtractionIsolate =
        await Isolate.spawn(_extractTextAsync, receivePort.sendPort);
  }

  static Future<void> _extractTextAsync(SendPort sendPort) async {
    final ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    final documentDetails = await receivePort.first;
    final SendPort replyPort = documentDetails[0];
    final Map<int, String> extractedTextCollection = <int, String>{};
    for (int i = 0; i < documentDetails[2]; i++) {
      extractedTextCollection[i] =
          documentDetails[1].extractText(startPageIndex: i).toLowerCase();
    }
    replyPort.send(extractedTextCollection);
  }

  void _killTextExtractionIsolate() {
    if (_textExtractionIsolate != null) {
      _textExtractionIsolate?.kill(priority: Isolate.immediate);
    }
  }

  Widget _showWebPasswordDialogue() {
    return Container(
      color: (_themeData!.colorScheme.brightness == Brightness.light)
          ? const Color(0xFFD6D6D6)
          : const Color(0xFF303030),
      child: Visibility(
        visible: _visibility,
        child: Center(
          child: Container(
            height: 225,
            width: 328,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: (_themeData!.colorScheme.brightness == Brightness.light)
                    ? Colors.white
                    : const Color(0xFF424242)),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 17, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        _localizations!.passwordDialogHeaderTextLabel,
                        style: _pdfViewerThemeData!
                                .passwordDialogStyle?.headerTextStyle ??
                            TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: _themeData!.colorScheme.onSurface
                                  .withOpacity(0.87),
                            ),
                      ),
                      SizedBox(
                        height: 36,
                        width: 36,
                        child: RawMaterialButton(
                          onPressed: () {
                            setState(() {
                              _focusNode.unfocus();
                              _textFieldController.clear();
                              _visibility = false;
                              _errorTextPresent = false;
                              _passwordVisible = true;
                            });
                          },
                          child: Icon(
                            Icons.clear,
                            color: _pdfViewerThemeData!
                                    .passwordDialogStyle?.closeIconColor ??
                                _themeData!.colorScheme.onSurface
                                    .withOpacity(0.6),
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                  child: Text(
                    _localizations!.passwordDialogContentLabel,
                    style: _pdfViewerThemeData!
                            .passwordDialogStyle?.contentTextStyle ??
                        TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: _themeData!.colorScheme.onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                ),
                SizedBox(
                  width: 296,
                  height: 70,
                  child: TextFormField(
                    style: _pdfViewerThemeData!
                            .passwordDialogStyle?.inputFieldTextStyle ??
                        TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: _themeData!.colorScheme.onSurface
                              .withOpacity(0.87),
                        ),
                    obscureText: _passwordVisible,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: _pdfViewerThemeData!
                                .passwordDialogStyle?.inputFieldBorderColor ??
                            _themeData!.colorScheme.primary,
                      )),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: _pdfViewerThemeData!
                                .passwordDialogStyle?.errorBorderColor ??
                            _themeData!.colorScheme.error,
                      )),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: _pdfViewerThemeData!
                                .passwordDialogStyle?.inputFieldBorderColor ??
                            _themeData!.colorScheme.primary,
                      )),
                      focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: _pdfViewerThemeData!
                                .passwordDialogStyle?.errorBorderColor ??
                            _themeData!.colorScheme.error,
                      )),
                      hintText: _localizations!.passwordDialogHintTextLabel,
                      errorText: _errorTextPresent ? 'Invalid Password' : null,
                      hintStyle: _pdfViewerThemeData!
                              .passwordDialogStyle?.inputFieldHintTextStyle ??
                          TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: _themeData!.colorScheme.onSurface
                                .withOpacity(0.6),
                          ),
                      labelText: _localizations!.passwordDialogHintTextLabel,
                      labelStyle: _pdfViewerThemeData!
                              .passwordDialogStyle?.inputFieldLabelTextStyle ??
                          TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: _errorTextPresent
                                ? _themeData!.colorScheme.error
                                : _themeData!.colorScheme.onSurface
                                    .withOpacity(0.87),
                          ),
                      errorStyle: _pdfViewerThemeData!
                              .passwordDialogStyle?.errorTextStyle ??
                          TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _themeData!.colorScheme.error,
                          ),
                      suffixIcon: IconButton(
                          icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: _pdfViewerThemeData!
                                      .passwordDialogStyle?.visibleIconColor ??
                                  Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6)),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          }),
                    ),
                    enableInteractiveSelection: false,
                    controller: _textFieldController,
                    autofocus: true,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.none,
                    onFieldSubmitted: (String value) {
                      _passwordValidation(value);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 16, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _textFieldController.clear();
                            _visibility = false;
                            _passwordVisible = true;
                            _errorTextPresent = false;
                          });
                        },
                        child: Text(
                          _localizations!.pdfPasswordDialogCancelLabel,
                          style: _pdfViewerThemeData!
                                  .passwordDialogStyle?.cancelTextStyle ??
                              TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _themeData!.colorScheme.primary,
                              ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _passwordValidation(_textFieldController.text);
                        },
                        child: Text(
                          _localizations!.pdfPasswordDialogOpenLabel,
                          style: _pdfViewerThemeData!
                                  .passwordDialogStyle?.openTextStyle ??
                              TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _themeData!.colorScheme.primary,
                              ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _passwordValidation(String password) {
    try {
      _decryptedProtectedDocument(_pdfBytes, password);
      setState(() {
        _textFieldController.clear();
        _visibility = false;
      });
    } catch (e) {
      if (widget.onDocumentLoadFailed != null) {
        if (password.isEmpty || _textFieldController.text.isEmpty) {
          widget.onDocumentLoadFailed!(PdfDocumentLoadFailedDetails(
              'Empty Password Error',
              'The provided `password` property is empty so unable to load the encrypted document.'));
        } else {
          widget.onDocumentLoadFailed!(PdfDocumentLoadFailedDetails(
              'Invalid Password Error',
              'The provided `password` property is invalid so unable to load the encrypted document.'));
        }
      }
      setState(() {
        _errorTextPresent = true;
        _textFieldController.clear();
      });
      _focusNode.requestFocus();
    }
  }

  Future<void> _showPasswordDialog() async {
    final TextDirection textDirection = Directionality.of(context);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final Orientation orientation = MediaQuery.of(context).orientation;
        return Directionality(
          textDirection: textDirection,
          child: AlertDialog(
            scrollable: true,
            insetPadding: EdgeInsets.zero,
            contentPadding: orientation == Orientation.portrait
                ? const EdgeInsets.all(24)
                : const EdgeInsets.only(right: 24, left: 24),
            buttonPadding: orientation == Orientation.portrait
                ? const EdgeInsets.all(8)
                : const EdgeInsets.all(4),
            backgroundColor: _pdfViewerThemeData!.backgroundColor ??
                (Theme.of(context).colorScheme.brightness == Brightness.light
                    ? Colors.white
                    : const Color(0xFF424242)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  _localizations!.passwordDialogHeaderTextLabel,
                  style: _pdfViewerThemeData!
                          .passwordDialogStyle?.headerTextStyle ??
                      TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color:
                            _themeData!.colorScheme.onSurface.withOpacity(0.87),
                      ),
                ),
                SizedBox(
                  height: 36,
                  width: 36,
                  child: RawMaterialButton(
                    onPressed: () {
                      _focusNode.unfocus();
                      _textFieldController.clear();
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.clear,
                      color: _pdfViewerThemeData!
                              .passwordDialogStyle?.closeIconColor ??
                          _themeData!.colorScheme.onSurface.withOpacity(0.6),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0))),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: SizedBox(
                  width: 328,
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: textDirection == TextDirection.ltr
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                          child: Text(
                            _localizations!.passwordDialogContentLabel,
                            style: _pdfViewerThemeData!
                                    .passwordDialogStyle?.contentTextStyle ??
                                TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: _themeData!.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                          ),
                        ),
                      ),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          style: _pdfViewerThemeData!
                                  .passwordDialogStyle?.inputFieldTextStyle ??
                              TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                color: _themeData!.colorScheme.onSurface
                                    .withOpacity(0.87),
                              ),
                          obscureText: _passwordVisible,
                          obscuringCharacter: '*',
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: _pdfViewerThemeData!.passwordDialogStyle
                                      ?.inputFieldBorderColor ??
                                  _themeData!.colorScheme.primary,
                            )),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3.5),
                                borderSide: BorderSide(
                                  color: _pdfViewerThemeData!
                                          .passwordDialogStyle
                                          ?.errorBorderColor ??
                                      _themeData!.colorScheme.error,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: _pdfViewerThemeData!.passwordDialogStyle
                                      ?.inputFieldBorderColor ??
                                  _themeData!.colorScheme.primary,
                            )),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: _pdfViewerThemeData!
                                      .passwordDialogStyle?.errorBorderColor ??
                                  _themeData!.colorScheme.error,
                            )),
                            hintText:
                                _localizations!.passwordDialogHintTextLabel,
                            hintStyle: _pdfViewerThemeData!.passwordDialogStyle
                                    ?.inputFieldHintTextStyle ??
                                TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: _themeData!.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                            labelText:
                                _localizations!.passwordDialogHintTextLabel,
                            labelStyle: _pdfViewerThemeData!.passwordDialogStyle
                                    ?.inputFieldLabelTextStyle ??
                                TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: _errorTextPresent
                                      ? _themeData!.colorScheme.error
                                      : _themeData!.colorScheme.onSurface
                                          .withOpacity(0.87),
                                ),
                            errorStyle: _pdfViewerThemeData!
                                    .passwordDialogStyle?.errorTextStyle ??
                                TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _themeData!.colorScheme.error,
                                ),
                            suffixIcon: IconButton(
                                icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: _pdfViewerThemeData!
                                            .passwordDialogStyle
                                            ?.visibleIconColor ??
                                        Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6)),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                }),
                          ),
                          enableInteractiveSelection: false,
                          controller: _textFieldController,
                          autofocus: true,
                          focusNode: _focusNode,
                          onFieldSubmitted: (String value) {
                            _handlePasswordValidation();
                          },
                          validator: (String? value) {
                            try {
                              _decryptedProtectedDocument(_pdfBytes, value);
                            } catch (e) {
                              if (widget.onDocumentLoadFailed != null) {
                                if (value!.isEmpty) {
                                  widget.onDocumentLoadFailed!(
                                      PdfDocumentLoadFailedDetails(
                                          'Empty Password Error',
                                          'The provided `password` property is empty so unable to load the encrypted document.'));
                                } else {
                                  widget.onDocumentLoadFailed!(
                                      PdfDocumentLoadFailedDetails(
                                          'Invalid Password Error',
                                          'The provided `password` property is invalid so unable to load the encrypted document.'));
                                }
                              }
                              _textFieldController.clear();
                              setState(() {
                                _errorTextPresent = true;
                              });
                              _focusNode.requestFocus();
                              return 'Invalid Password';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  _textFieldController.clear();
                  Navigator.of(context).pop();
                },
                child: Text(
                  _localizations!.pdfPasswordDialogCancelLabel,
                  style: _pdfViewerThemeData!
                          .passwordDialogStyle?.cancelTextStyle ??
                      TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _themeData!.colorScheme.primary,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                child: TextButton(
                  onPressed: () {
                    _handlePasswordValidation();
                  },
                  child: Text(
                    _localizations!.pdfPasswordDialogOpenLabel,
                    style: _pdfViewerThemeData!
                            .passwordDialogStyle?.openTextStyle ??
                        TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _themeData!.colorScheme.primary,
                        ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handlePasswordValidation() {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _textFieldController.clear();
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _decryptedProtectedDocument(Uint8List pdfBytes, String? password) {
    final PdfDocument document =
        PdfDocument(inputBytes: pdfBytes, password: password);
    document.security.userPassword = '';
    document.security.ownerPassword = '';
    final List<int> bytes = document.saveSync();
    _decryptedBytes = Uint8List.fromList(bytes);
    _isEncrypted = true;
    _loadPdfDocument(true);
  }

  Future<PdfDocument?> _getPdfFile(Uint8List? value) async {
    if (value != null) {
      return PdfDocument(inputBytes: value);
    }
    return null;
  }

  void _isDocumentLoaded() {
    if (_pdfPages.isNotEmpty &&
        !_isDocumentLoadInitiated &&
        ((!_pdfDimension.isEmpty &&
                _pdfScrollableStateKey.currentState != null) ||
            (widget.pageLayoutMode == PdfPageLayoutMode.single &&
                _pageController.hasClients))) {
      _isDocumentLoadInitiated = true;
      _previousHorizontalOffset = 0;
      _isPdfPagesLoaded();
    } else if (_layoutChangeOffset != Offset.zero &&
        (!_pdfDimension.isEmpty &&
            _pdfScrollableStateKey.currentState != null)) {
      final double xOffset =
          widget.scrollDirection != PdfScrollDirection.vertical
              ? _pdfPages[_previousSinglePage]!.pageOffset
              : 0;
      final double yOffset =
          widget.scrollDirection == PdfScrollDirection.vertical
              ? _pdfPages[_previousSinglePage]!.pageOffset
              : 0;
      _pdfScrollableStateKey.currentState!.jumpTo(
          xOffset: xOffset + _layoutChangeOffset.dx,
          yOffset: yOffset + _layoutChangeOffset.dy);
      _layoutChangeOffset = Offset.zero;
      _previousSinglePage = 1;
    }
  }

  void _isPdfPagesLoaded() {
    if (_isDocumentLoadInitiated) {
      if (widget.initialScrollOffset == Offset.zero ||
          _pdfViewerController._verticalOffset != 0.0 ||
          _pdfViewerController._horizontalOffset != 0.0) {
        _pdfViewerController.jumpTo(
            xOffset: _pdfViewerController._horizontalOffset,
            yOffset: _pdfViewerController._verticalOffset);
      }
      _pdfViewerController._notifyPropertyChangedListeners(
          property: 'pageNavigate');
      _pdfViewerController._notifyPropertyChangedListeners(
          property: 'jumpToBookmark');
      if (_pdfViewerController._searchText.isNotEmpty) {
        _pdfViewerController._notifyPropertyChangedListeners(
            property: 'searchText');
      }
      if (_pdfViewerController.zoomLevel > 1 &&
          widget.pageLayoutMode == PdfPageLayoutMode.single) {
        _singlePageViewKey.currentState!
            .scaleTo(_pdfViewerController.zoomLevel);
      }
    }
  }

  void _findDevice(BuildContext context) {
    const double kPdfStandardDiagonalOffset = 1100.0;
    final Size size = MediaQuery.of(context).size;
    final double diagonal =
        sqrt((size.width * size.width) + (size.height * size.height));
    _isMobile = diagonal < kPdfStandardDiagonalOffset;
  }

  Rect? _getViewportGlobalRect() {
    Rect? viewportGlobalRect;
    if (kIsDesktop &&
        !_isMobile &&
        ((widget.pageLayoutMode == PdfPageLayoutMode.single &&
                _singlePageViewKey.currentContext != null) ||
            (_pdfScrollableStateKey.currentContext != null &&
                widget.pageLayoutMode == PdfPageLayoutMode.continuous))) {
      RenderBox viewportRenderBox;
      if (widget.pageLayoutMode == PdfPageLayoutMode.single) {
        viewportRenderBox = (_singlePageViewKey.currentContext!
            .findRenderObject())! as RenderBox;
      } else {
        viewportRenderBox = (_pdfScrollableStateKey.currentContext!
            .findRenderObject())! as RenderBox;
      }
      final Offset position = viewportRenderBox.localToGlobal(Offset.zero);
      final Size containerSize = viewportRenderBox.size;
      viewportGlobalRect = Rect.fromLTWH(
          position.dx, position.dy, containerSize.width, containerSize.height);
    }
    return viewportGlobalRect;
  }

  @override
  Widget build(BuildContext context) {
    final Container emptyContainer = Container(
      color: _pdfViewerThemeData!.backgroundColor ??
          (_themeData!.colorScheme.brightness == Brightness.light
              ? const Color(0xFFD6D6D6)
              : const Color(0xFF303030)),
    );
    final Stack emptyLinearProgressView = Stack(
      children: <Widget>[
        emptyContainer,
        LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              _pdfViewerThemeData!.progressBarColor ??
                  _themeData!.colorScheme.primary),
          backgroundColor: _pdfViewerThemeData!.progressBarColor == null
              ? _themeData!.colorScheme.primary.withOpacity(0.2)
              : _pdfViewerThemeData!.progressBarColor!.withOpacity(0.2),
        ),
      ],
    );

    _isDocumentLoaded();

    _findDevice(context);

    final bool isPdfLoaded = _pdfViewerController.pageCount > 0 &&
        _originalWidth != null &&
        _originalHeight != null;
    _pdfDimension =
        (_childKey.currentContext?.findRenderObject()?.paintBounds.size) ??
            Size.zero;
    return isPdfLoaded
        ? Listener(
            onPointerSignal: _handlePointerSignal,
            onPointerDown: _handlePointerDown,
            onPointerMove: _handlePointerMove,
            onPointerUp: _handlePointerUp,
            child: Container(
              color: _pdfViewerThemeData!.backgroundColor ??
                  (_themeData!.colorScheme.brightness == Brightness.light
                      ? const Color(0xFFD6D6D6)
                      : const Color(0xFF303030)),
              child: FutureBuilder(
                  future: _getImages(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      final dynamic pdfImages = snapshot.data;
                      _renderedImages.clear();
                      _textDirection = Directionality.of(context);
                      _viewportConstraints = context
                          .findRenderObject()!
                          .constraints as BoxConstraints;
                      double totalHeight = 0.0;
                      _isKeyPadRaised =
                          WidgetsBinding.instance.window.viewInsets.bottom !=
                              0.0;
                      Size viewportDimension = _viewportConstraints.biggest;
                      if (_isKeyPadRaised) {
                        _iskeypadClosed = true;
                        double keyPadHeight = EdgeInsets.fromWindowPadding(
                                WidgetsBinding.instance.window.viewInsets,
                                WidgetsBinding.instance.window.devicePixelRatio)
                            .bottom;
                        if ((widget.scrollDirection ==
                                    PdfScrollDirection.horizontal ||
                                widget.pageLayoutMode ==
                                    PdfPageLayoutMode.single) &&
                            keyPadHeight > 0) {
                          if (viewportDimension.height + keyPadHeight !=
                              _viewportHeight) {
                            keyPadHeight =
                                _viewportHeight - viewportDimension.height;
                          } else {
                            _viewportHeight =
                                viewportDimension.height + keyPadHeight;
                          }
                        }

                        viewportDimension = Size(viewportDimension.width,
                            viewportDimension.height + keyPadHeight);
                      } else {
                        if (_iskeypadClosed) {
                          viewportDimension =
                              Size(viewportDimension.width, _viewportHeight);
                          _iskeypadClosed = false;
                        } else {
                          _viewportHeight = viewportDimension.height;
                        }
                      }
                      if (!isBookmarkViewOpen) {
                        _otherContextHeight ??=
                            MediaQuery.of(context).size.height -
                                _viewportConstraints.maxHeight;
                      }
                      if (_deviceOrientation == Orientation.landscape) {
                        _viewportHeightInLandscape ??=
                            MediaQuery.of(context).size.height -
                                _otherContextHeight!;
                      }
                      if (!_pdfDimension.isEmpty) {
                        if (_scrollDirection == PdfScrollDirection.vertical) {
                          _maxScrollExtent = _pdfDimension.height -
                              (viewportDimension.height /
                                  _pdfViewerController.zoomLevel);
                        } else {
                          _maxScrollExtent = _pdfDimension.width -
                              (viewportDimension.width /
                                  _pdfViewerController.zoomLevel);
                        }
                      }
                      Widget child;
                      final List<Widget> children = List<Widget>.generate(
                          _pdfViewerController.pageCount, (int index) {
                        if (index == 0) {
                          totalHeight = 0;
                        }
                        if (_originalWidth!.length !=
                            _pdfViewerController.pageCount) {
                          return emptyContainer;
                        }
                        final int pageIndex = index + 1;
                        final Size calculatedSize = _calculateSize(
                            BoxConstraints(
                                maxWidth: _viewportConstraints.maxWidth),
                            _originalWidth![index],
                            _originalHeight![index],
                            _viewportConstraints.maxWidth,
                            viewportDimension.height);
                        if (!_pdfPagesKey.containsKey(pageIndex)) {
                          _pdfPagesKey[pageIndex] = GlobalKey();
                        }
                        _isOverflowed = _originalWidth![index] >
                            _viewportConstraints.maxWidth as bool;
                        if (kIsDesktop && !_isMobile) {
                          if (_originalWidth![index] > _maxPdfPageWidth !=
                              null) {
                            _maxPdfPageWidth = _originalWidth![index] as double;
                          }
                        }
                        if (pdfImages[pageIndex] != null) {
                          if (_pageTextExtractor.isEmpty ||
                              !_pageTextExtractor.containsKey(index)) {
                            _pageTextExtractor[index] = _pdfTextExtractor!
                                .extractText(startPageIndex: index);
                          }
                        }
                        Rect? viewportGlobalRect;
                        if (_isTextSelectionCleared) {
                          viewportGlobalRect = _getViewportGlobalRect();
                        }
                        final PdfPageView page = PdfPageView(
                          _pdfPagesKey[pageIndex]!,
                          pdfImages[pageIndex],
                          viewportGlobalRect,
                          viewportDimension,
                          widget.interactionMode,
                          (kIsDesktop &&
                                  !_isMobile &&
                                  !_isOverflowed &&
                                  widget.pageLayoutMode ==
                                      PdfPageLayoutMode.continuous)
                              ? _originalWidth![index]
                              : calculatedSize.width,
                          (kIsDesktop &&
                                  !_isMobile &&
                                  !_isOverflowed &&
                                  widget.pageLayoutMode ==
                                      PdfPageLayoutMode.continuous)
                              ? _originalHeight![index]
                              : calculatedSize.height,
                          widget.pageSpacing,
                          _document,
                          _pdfPages,
                          index,
                          _pdfViewerController,
                          widget.enableDocumentLinkAnnotation,
                          widget.enableTextSelection,
                          widget.onTextSelectionChanged,
                          widget.onHyperlinkClicked,
                          _handleTextSelectionDragStarted,
                          _handleTextSelectionDragEnded,
                          widget.currentSearchTextHighlightColor,
                          widget.otherSearchTextHighlightColor,
                          _textCollection,
                          _isMobile,
                          _pdfViewerController._pdfTextSearchResult,
                          _pdfScrollableStateKey,
                          _singlePageViewKey,
                          _scrollDirection,
                          _handlePdfPagePointerDown,
                          _handlePdfPagePointerMove,
                          _handlePdfPagePointerUp,
                          isBookmarkViewOpen ? '' : _pageTextExtractor[index],
                          widget.pageLayoutMode == PdfPageLayoutMode.single,
                          _textDirection,
                          widget.canShowHyperlinkDialog,
                          widget.enableHyperlinkNavigation,
                        );
                        final double pageSpacing =
                            index == _pdfViewerController.pageCount - 1
                                ? 0.0
                                : widget.pageSpacing;
                        if (kIsDesktop && !_isMobile && !_isOverflowed) {
                          _pdfPages[pageIndex] = PdfPageInfo(
                              totalHeight,
                              Size(_originalWidth![index],
                                  _originalHeight![index]));
                          if (_scrollDirection == PdfScrollDirection.vertical &&
                              widget.pageLayoutMode !=
                                  PdfPageLayoutMode.single) {
                            totalHeight +=
                                _originalHeight![index] + pageSpacing;
                          } else {
                            if (widget.pageLayoutMode ==
                                PdfPageLayoutMode.continuous) {
                              totalHeight +=
                                  _originalWidth![index] + pageSpacing;
                            } else {
                              _pdfPages[pageIndex] =
                                  PdfPageInfo(totalHeight, calculatedSize);
                              totalHeight +=
                                  calculatedSize.height + pageSpacing;
                            }
                          }
                        } else {
                          _pdfPages[pageIndex] =
                              PdfPageInfo(totalHeight, calculatedSize);
                          if (_scrollDirection == PdfScrollDirection.vertical &&
                              widget.pageLayoutMode !=
                                  PdfPageLayoutMode.single) {
                            totalHeight += calculatedSize.height + pageSpacing;
                          } else {
                            totalHeight += calculatedSize.width + pageSpacing;
                          }
                        }
                        _updateScrollDirectionChange(
                            _offsetBeforeOrientationChange,
                            pageIndex,
                            totalHeight);
                        _updateOffsetOnOrientationChange(
                            _offsetBeforeOrientationChange,
                            pageIndex,
                            totalHeight);
                        if (_pdfPagesKey[_pdfViewerController.pageNumber]
                                    ?.currentState
                                    ?.canvasRenderBox !=
                                null &&
                            !_isTextSelectionCleared) {
                          _isTextSelectionCleared = true;
                          if (kIsWeb ||
                              !Platform.environment
                                  .containsKey('FLUTTER_TEST')) {
                            Future<dynamic>.delayed(Duration.zero, () async {
                              _clearSelection();
                              _pdfPagesKey[_pdfViewerController.pageNumber]
                                  ?.currentState
                                  ?.canvasRenderBox
                                  ?.disposeMouseSelection();
                              _pdfPagesKey[_pdfViewerController.pageNumber]
                                  ?.currentState
                                  ?.focusNode
                                  .requestFocus();
                            });
                          }
                        }
                        if (page.imageStream != null) {
                          _renderedImages.add(pageIndex);
                        }
                        return page;
                      });
                      Widget? pdfContainer;
                      if (widget.pageLayoutMode == PdfPageLayoutMode.single) {
                        _pageController = PageController(
                            initialPage: _pdfViewerController.pageNumber - 1);
                        pdfContainer = MouseRegion(
                          cursor: _cursor,
                          onHover: (PointerHoverEvent details) {
                            setState(() {
                              if (widget.interactionMode ==
                                  PdfInteractionMode.pan) {
                                _cursor = SystemMouseCursors.grab;
                              } else {
                                _cursor = SystemMouseCursors.basic;
                              }
                            });
                          },
                          child: SinglePageView(
                              _singlePageViewKey,
                              _pdfViewerController,
                              _pageController,
                              _handleSinglePageViewPageChanged,
                              _interactionUpdate,
                              viewportDimension,
                              widget.canShowPaginationDialog,
                              widget.canShowScrollHead,
                              widget.canShowScrollStatus,
                              _pdfPages,
                              _isMobile,
                              widget.enableDoubleTapZooming,
                              widget.interactionMode,
                              _isScaleEnabled,
                              _handleSinglePageViewZoomLevelChanged,
                              _handleDoubleTap,
                              _handlePdfOffsetChanged,
                              isBookmarkViewOpen,
                              _textDirection,
                              children),
                        );
                        if (_isSinglePageViewPageChanged &&
                            _renderedImages
                                .contains(_pdfViewerController.pageNumber)) {
                          Future<dynamic>.delayed(Duration.zero, () async {
                            if (_pageController.hasClients) {
                              _pdfViewerController._scrollPositionX =
                                  _pageController.offset;
                            }
                            if (!_isSearchStarted) {
                              _pdfPagesKey[_pdfViewerController.pageNumber]
                                  ?.currentState
                                  ?.focusNode
                                  .requestFocus();
                            }
                            if (getSelectedTextLines().isNotEmpty &&
                                getSelectedTextLines().first.pageNumber + 1 ==
                                    _pdfViewerController.pageNumber) {
                              _pdfPagesKey[_pdfViewerController.pageNumber]
                                  ?.currentState
                                  ?.canvasRenderBox
                                  ?.updateContextMenuPosition();
                            }
                            _isSinglePageViewPageChanged = false;
                          });
                        }
                      } else {
                        final Size childSize = _getChildSize(viewportDimension);
                        if (_scrollDirection == PdfScrollDirection.horizontal) {
                          child = Row(
                              key: _childKey,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: children);
                        } else {
                          child = Column(
                              key: _childKey,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: children);
                        }
                        child = MouseRegion(
                          cursor: _cursor,
                          onHover: (PointerHoverEvent details) {
                            setState(() {
                              if (widget.interactionMode ==
                                  PdfInteractionMode.pan) {
                                _cursor = SystemMouseCursors.grab;
                              } else {
                                _cursor = SystemMouseCursors.basic;
                              }
                            });
                          },
                          child: SizedBox(
                              height: childSize.height,
                              width: childSize.width,
                              child: child),
                        );
                        pdfContainer = PdfScrollable(
                          widget.canShowPaginationDialog,
                          widget.canShowScrollStatus,
                          widget.canShowScrollHead,
                          _pdfViewerController,
                          _isMobile,
                          _pdfDimension,
                          _totalImageSize,
                          viewportDimension,
                          _handlePdfOffsetChanged,
                          _panEnabled,
                          _maxScale,
                          _minScale,
                          widget.enableDoubleTapZooming,
                          widget.interactionMode,
                          _maxPdfPageWidth,
                          _isScaleEnabled,
                          _maxScrollExtent,
                          _pdfPages,
                          _scrollDirection,
                          isBookmarkViewOpen,
                          _textDirection,
                          child,
                          key: _pdfScrollableStateKey,
                          onDoubleTap: _handleDoubleTap,
                        );

                        if (_isScrollDirectionChange) {
                          _pdfScrollableStateKey.currentState
                              ?.forcePixels(_scrollDirectionSwitchOffset);
                          _isScrollDirectionChange = false;
                        }
                      }
                      return Stack(
                        children: <Widget>[
                          if (widget.showContents) pdfContainer,
                          BookmarkView(
                              _bookmarkKey,
                              _document,
                              _pdfViewerController,
                              _handleBookmarkViewChanged,
                              _textDirection),
                          if (widget.customBookmarkBuilder != null)
                            widget.customBookmarkBuilder!(BookmarkView(
                                _bookmarkKey,
                                _document,
                                _pdfViewerController,
                                _handleBookmarkViewChanged,
                                _textDirection))
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return emptyContainer;
                    } else {
                      return emptyLinearProgressView;
                    }
                  }),
            ),
          )
        : (_hasError
            ? _isEncryptedDocument
                ? _showWebPasswordDialogue()
                : emptyContainer
            : emptyLinearProgressView);
  }

  void _handleSinglePageViewPageChanged(int newPage) {
    _pdfViewerController._pageNumber = newPage + 1;
    _pdfViewerController._zoomLevel = 1.0;
    if (_singlePageViewKey.currentState != null) {
      _singlePageViewKey.currentState!.previousZoomLevel = 1;
      _pdfViewerController._notifyPropertyChangedListeners(
          property: 'zoomLevel');
    }
    _previousHorizontalOffset = 0.0;
    _pageChanged();
    _isZoomChanged = true;
    _checkMount();
    _isSinglePageViewPageChanged = true;
    if (widget.onTextSelectionChanged != null) {
      widget
          .onTextSelectionChanged!(PdfTextSelectionChangedDetails(null, null));
    }
  }

  void _interactionUpdate(double zoomLevel) {
    _pdfViewerController._zoomLevel = zoomLevel;
  }

  void _handleSinglePageViewZoomLevelChanged(double zoomLevel) {
    if (_singlePageViewKey.currentState != null) {
      final double previousScale =
          _singlePageViewKey.currentState!.previousZoomLevel;
      if (previousScale != _pdfViewerController._zoomLevel) {
        _pdfViewerController._notifyPropertyChangedListeners(
            property: 'zoomLevel');
      }
    }
  }

  Size _getChildSize(Size viewportDimension) {
    double widthFactor = 1.0, heightFactor = 1.0;
    double childHeight = 0, childWidth = 0;

    if (_pdfScrollableStateKey.currentState != null) {
      widthFactor = _pdfScrollableStateKey.currentState!.paddingWidthScale == 0
          ? _pdfViewerController.zoomLevel
          : _pdfScrollableStateKey.currentState!.paddingWidthScale;
      heightFactor =
          _pdfScrollableStateKey.currentState!.paddingHeightScale == 0
              ? _pdfViewerController.zoomLevel
              : _pdfScrollableStateKey.currentState!.paddingHeightScale;
    }
    if (_pdfPages[_pdfViewerController.pageCount] != null) {
      final PdfPageInfo lastPageInfo =
          _pdfPages[_pdfViewerController.pageCount]!;
      final double zoomLevel = _pdfViewerController.zoomLevel;
      final Size currentPageSize =
          _pdfPages[_pdfViewerController.pageNumber]!.pageSize;
      double totalImageWidth =
          (lastPageInfo.pageOffset + lastPageInfo.pageSize.width) * zoomLevel;
      if (_scrollDirection == PdfScrollDirection.vertical) {
        totalImageWidth = currentPageSize.width * zoomLevel;
      }
      childWidth = viewportDimension.width > totalImageWidth
          ? viewportDimension.width / widthFactor.clamp(1, 3)
          : totalImageWidth / widthFactor.clamp(1, 3);

      double totalImageHeight = currentPageSize.height * zoomLevel;
      if (_scrollDirection == PdfScrollDirection.vertical) {
        totalImageHeight =
            (lastPageInfo.pageOffset + lastPageInfo.pageSize.height) *
                zoomLevel;
      }
      childHeight = viewportDimension.height > totalImageHeight
          ? viewportDimension.height / heightFactor.clamp(1, 3)
          : totalImageHeight / heightFactor.clamp(1, 3);
      _totalImageSize =
          Size(totalImageWidth / zoomLevel, totalImageHeight / zoomLevel);
      if (_isMobile &&
          !_isKeyPadRaised &&
          childHeight > _viewportConstraints.maxHeight &&
          (totalImageHeight / zoomLevel).floor() <=
              _viewportConstraints.maxHeight.floor()) {
        childHeight = _viewportConstraints.maxHeight;
      }
      if (_isMobile &&
          childWidth > _viewportConstraints.maxWidth &&
          totalImageWidth / zoomLevel <= _viewportConstraints.maxWidth) {
        childWidth = _viewportConstraints.maxWidth;
      }
    }
    return Size(childWidth, childHeight);
  }

  void _handlePdfPagePointerDown(PointerDownEvent details) {
    _isPdfPageTapped = true;
  }

  void _handlePdfPagePointerMove(PointerMoveEvent details) {
    if (details.kind == PointerDeviceKind.touch && kIsDesktop && !_isMobile) {
      setState(() {
        _isScaleEnabled = true;
      });
    }
  }

  void _handlePdfPagePointerUp(PointerUpEvent details) {
    if (details.kind == PointerDeviceKind.touch && kIsDesktop && !_isMobile) {
      setState(() {
        _isScaleEnabled = false;
      });
    }
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (!isBookmarkViewOpen) {
      _pdfScrollableStateKey.currentState?.receivedPointerSignal(event);
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!_isPdfPageTapped) {
      _pdfPagesKey[_pdfViewerController.pageNumber]
          ?.currentState
          ?.canvasRenderBox
          ?.clearSelection();
    }
    _pdfPagesKey[_pdfViewerController.pageNumber]
        ?.currentState
        ?.focusNode
        .requestFocus();
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (widget.interactionMode == PdfInteractionMode.pan) {
      _cursor = SystemMouseCursors.grabbing;
    }
    if (!_isScaleEnabled &&
        event.kind == PointerDeviceKind.touch &&
        (!kIsDesktop || _isMobile)) {
      setState(() {
        _isScaleEnabled = true;
      });
    }
    _pdfPagesKey[_pdfViewerController.pageNumber]
        ?.currentState
        ?.canvasRenderBox
        ?.scrollStarted();
  }

  void _handlePointerUp(PointerUpEvent details) {
    _isPdfPageTapped = false;
    if (widget.interactionMode == PdfInteractionMode.pan) {
      _cursor = SystemMouseCursors.grab;
    }
    _pdfPagesKey[_pdfViewerController.pageNumber]
        ?.currentState
        ?.canvasRenderBox
        ?.scrollEnded();
  }

  void _handleDoubleTap() {
    _checkMount();
    if (!kIsDesktop || _isMobile) {
      _pdfPagesKey[_pdfViewerController.pageNumber]
          ?.currentState
          ?.canvasRenderBox
          ?.updateContextMenuPosition();
    }
  }

  void _handleBookmarkViewChanged(bool hasBookmark) {
    if (!kIsWeb || (kIsWeb && _isMobile)) {
      _checkMount();
    }
  }

  void openBookmarkView() {
    _bookmarkKey.currentState?.open();
  }

  List<PdfTextLine> getSelectedTextLines() {
    final List<PdfTextLine>? selectedTextLines =
        _pdfPagesKey[_pdfViewerController.pageNumber]
            ?.currentState
            ?.canvasRenderBox
            ?.getSelectedTextLines();
    return selectedTextLines ?? <PdfTextLine>[];
  }

  int _findStartOrEndPage(int pageIndex, bool isLastPage) {
    double pageSize = 0.0;
    for (int start = isLastPage
            ? _pdfViewerController.pageCount
            : _pdfViewerController.pageNumber;
        isLastPage ? start >= 1 : start <= _pdfViewerController.pageCount;
        isLastPage ? start-- : start++) {
      pageSize += _scrollDirection == PdfScrollDirection.vertical
          ? _pdfPages[start]!.pageSize.height
          : _pdfPages[start]!.pageSize.width;
      if ((!isLastPage && start == _pdfViewerController.pageCount) ||
          (isLastPage && start == 1)) {
        pageIndex = start;
        break;
      } else {
        pageIndex = isLastPage ? start - 1 : start + 1;
      }
      final bool isPageIndexFound =
          _scrollDirection == PdfScrollDirection.vertical
              ? pageSize > _viewportConstraints.biggest.height
              : pageSize > _viewportConstraints.biggest.width;
      if (isPageIndexFound) {
        break;
      }
    }
    return pageIndex;
  }

  Future<Map<int, List<dynamic>>?>? _getImages() {
    if (widget.pageLayoutMode == PdfPageLayoutMode.single) {
      Future<Map<int, List<dynamic>>?>? renderedPages;
      final int startPage = _pdfViewerController.pageNumber - 1 != 0
          ? _pdfViewerController.pageNumber - 1
          : _pdfViewerController.pageNumber;
      final int endPage =
          _pdfViewerController.pageNumber + 1 < _pdfViewerController.pageCount
              ? _pdfViewerController.pageNumber + 1
              : _pdfViewerController.pageCount;
      final bool canRenderImage =
          !(_singlePageViewKey.currentState?.isScrollHeadDragged ?? true);
      renderedPages = _plugin
          .getSpecificPages(
              startPage,
              endPage,
              _pdfViewerController.zoomLevel,
              _isZoomChanged || (_isPageChanged && !_isOrientationChanged),
              _pdfViewerController.pageNumber,
              canRenderImage && !_isOrientationChanged)
          .then((Map<int, List<dynamic>>? value) {
        _isZoomChanged = false;
        return value;
      });
      if (_isOrientationChanged && canRenderImage) {
        _isOrientationChanged = false;
      }
      if (!_renderedImages.contains(_pdfViewerController.pageNumber)) {
        renderedPages.whenComplete(_checkMount);
      }
      return renderedPages;
    } else {
      int startPage = (kIsDesktop && _pdfViewerController.pageNumber != 1)
          ? _pdfViewerController.pageNumber - 1
          : _pdfViewerController.pageNumber;
      int endPage = _pdfViewerController.pageNumber;
      Future<Map<int, List<dynamic>>?>? renderedPages;
      if (_pdfPages.isNotEmpty && !_pdfDimension.isEmpty) {
        if (_pdfViewerController.pageCount == 1) {
          endPage = _pdfViewerController.pageCount;
        } else {
          if (startPage == _pdfViewerController.pageCount) {
            startPage = _findStartOrEndPage(startPage, true);
            endPage = _pdfViewerController.pageCount;
          } else {
            endPage = _findStartOrEndPage(endPage, false);
            if (kIsDesktop && endPage + 1 <= _pdfViewerController.pageCount) {
              endPage = endPage + 1;
            }
          }
        }
      }
      if (_pdfViewerController.zoomLevel >= 2) {
        startPage = _endPage = _pdfViewerController.pageNumber;
      }
      bool canRenderImage = !(_pdfScrollableStateKey.currentState
                  ?.scrollHeadStateKey.currentState?.isScrollHeadDragged ??
              true) &&
          !(widget.scrollDirection == PdfScrollDirection.vertical
              ? _pdfScrollableStateKey.currentState?.scrollHeadStateKey
                      .currentState?.isScrolled ??
                  false
              : (_pdfScrollableStateKey.currentState?.isScrolled ?? false));
      if (_pdfScrollableStateKey.currentState?.isZoomChanged ?? false)
        canRenderImage = true;
      renderedPages = _plugin
          .getSpecificPages(
              startPage,
              endPage,
              _pdfViewerController.zoomLevel,
              _isZoomChanged || (_isPageChanged && !_isOrientationChanged),
              _pdfViewerController.pageNumber,
              (canRenderImage || !_isDocumentLoadInitiated) &&
                  !_isOrientationChanged)
          .then((Map<int, List<dynamic>>? value) {
        if ((_pdfPages.isNotEmpty && !_pdfDimension.isEmpty) ||
            _isZoomChanged) {
          for (int i = startPage; i <= endPage; i++) {
            if (!_renderedImages.contains(i) || _isZoomChanged) {
              _isZoomChanged = false;
              _checkMount();
              break;
            }
          }
        }
        return value;
      });
      if (_isOrientationChanged &&
          widget.scrollDirection == PdfScrollDirection.horizontal &&
          _deviceOrientation == MediaQuery.of(context).orientation) {
        _isOrientationChanged = false;
      }
      if (_isOrientationChanged &&
          (!canRenderImage ||
              _deviceOrientation == MediaQuery.of(context).orientation) &&
          widget.scrollDirection == PdfScrollDirection.vertical) {
        _isOrientationChanged = false;
      }
      if ((_startPage != startPage && _endPage != endPage) ||
          (_bufferCount > 0 && _bufferCount <= (endPage - startPage) + 1)) {
        renderedPages.whenComplete(_checkMount);
        _startPage = startPage;
        _endPage = endPage;
        _bufferCount++;
      } else {
        _bufferCount = 0;
      }
      if (canRenderImage) {
        renderedPages.whenComplete(() {
          _checkMount();
        });
      }
      return renderedPages;
    }
  }

  void _checkMount() {
    if (super.mounted) {
      setState(() {});
    }
  }

  void _pageChanged() {
    if (_pdfViewerController.pageNumber != _previousPageNumber) {
      if (widget.onPageChanged != null) {
        widget.onPageChanged!(PdfPageChangedDetails(
          _pdfViewerController.pageNumber,
          _previousPageNumber,
          _pdfViewerController.pageNumber == 1,
          _pdfViewerController.pageNumber == _pdfViewerController.pageCount,
        ));
      }
      _previousPageNumber = _pdfViewerController.pageNumber;
      _isPageChanged = true;
    }
  }

  void _updateSearchInstance({bool isNext = true}) {
    if (_textCollection != null &&
        _pdfViewerController._pdfTextSearchResult.hasResult &&
        _pdfViewerController.pageNumber !=
            (_textCollection![_pdfViewerController
                            ._pdfTextSearchResult.currentInstanceIndex -
                        1]
                    .pageIndex +
                1)) {
      _pdfViewerController._pdfTextSearchResult._currentOccurrenceIndex =
          _getInstanceInPage(_pdfViewerController.pageNumber,
              lookForFirst: isNext);
    }
  }

  void _updateOffsetOnOrientationChange(
      Offset initialOffset, int pageIndex, double totalHeight) {
    if (_viewportWidth != _viewportConstraints.maxWidth &&
        _deviceOrientation != MediaQuery.of(context).orientation) {
      WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
        _checkMount();
      });
      if (pageIndex == 1 &&
          !_viewportConstraints.biggest.isEmpty &&
          _pdfScrollableStateKey.currentState != null) {
        _offsetBeforeOrientationChange = Offset(
            _pdfScrollableStateKey.currentState!.currentOffset.dx /
                _pdfDimension.width,
            _pdfScrollableStateKey.currentState!.currentOffset.dy /
                _pdfDimension.height);
        if (_pdfViewerController.pageCount == 1 &&
            _pdfScrollableStateKey.currentState != null) {
          if (_viewportWidth != 0) {
            final double targetOffset = initialOffset.dy * totalHeight;
            WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
              _pdfPagesKey[_pdfViewerController.pageNumber]
                  ?.currentState
                  ?.canvasRenderBox
                  ?.updateContextMenuPosition();
              _pdfScrollableStateKey.currentState?.forcePixels(Offset(
                  initialOffset.dx * _viewportConstraints.biggest.width,
                  targetOffset));
            });
          }
          _viewportWidth = _viewportConstraints.maxWidth;

          _deviceOrientation = MediaQuery.of(context).orientation;
        }
      } else if (pageIndex == _pdfViewerController.pageCount) {
        if (_viewportWidth != 0) {
          double targetOffset;
          if (_scrollDirection == PdfScrollDirection.vertical &&
              widget.pageLayoutMode != PdfPageLayoutMode.single) {
            targetOffset = initialOffset.dy * totalHeight;
          } else {
            targetOffset = initialOffset.dx * totalHeight;
          }
          WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
            _pdfPagesKey[_pdfViewerController.pageNumber]
                ?.currentState
                ?.canvasRenderBox
                ?.updateContextMenuPosition();
            if (_scrollDirection == PdfScrollDirection.vertical &&
                widget.pageLayoutMode != PdfPageLayoutMode.single) {
              _pdfScrollableStateKey.currentState?.forcePixels(Offset(
                  initialOffset.dx * _viewportConstraints.biggest.width,
                  targetOffset));
            } else {
              _pdfScrollableStateKey.currentState?.forcePixels(Offset(
                  targetOffset,
                  initialOffset.dy *
                      _pdfPages[_pdfViewerController.pageNumber]!
                          .pageSize
                          .height));
            }
          });
        }
        _viewportWidth = _viewportConstraints.maxWidth;

        _deviceOrientation = MediaQuery.of(context).orientation;
      }
    }
  }

  void _updateOffsetOnLayoutChange(
      double zoomLevel, Offset scrollOffset, PdfPageLayoutMode oldLayoutMode) {
    if (oldLayoutMode != widget.pageLayoutMode &&
        oldLayoutMode == PdfPageLayoutMode.single) {
      _previousSinglePage = _pdfViewerController.pageNumber;
      final double greyArea =
          (_singlePageViewKey.currentState?.greyAreaSize ?? 0) / 2;
      double heightPercentage = 1.0;
      if (kIsDesktop && !_isMobile) {
        heightPercentage =
            _document!.pages[_pdfViewerController.pageNumber - 1].size.height /
                _pdfPages[_pdfViewerController.pageNumber]!.pageSize.height;
      }
      Offset singleOffset =
          _singlePageViewKey.currentState?.currentOffset ?? Offset.zero;
      singleOffset = Offset(singleOffset.dx * heightPercentage,
          (singleOffset.dy - greyArea) * heightPercentage);
      _layoutChangeOffset = singleOffset;
    } else {
      double xPosition = scrollOffset.dx;
      double yPosition = scrollOffset.dy;
      if (_pdfViewerController.pageNumber > 1 &&
          widget.scrollDirection == PdfScrollDirection.vertical) {
        yPosition = scrollOffset.dy -
            _pdfPages[_pdfViewerController.pageNumber]!.pageOffset;
      }
      if (_pdfViewerController.pageNumber > 1 &&
          widget.scrollDirection == PdfScrollDirection.horizontal) {
        xPosition = scrollOffset.dx -
            _pdfPages[_pdfViewerController.pageNumber]!.pageOffset;
      }
      Future<dynamic>.delayed(Duration.zero, () async {
        if (widget.pageLayoutMode == PdfPageLayoutMode.single) {
          _pdfViewerController.zoomLevel = 1.0;
        }
        _pdfViewerController.zoomLevel = zoomLevel;
        double heightPercentage = 1.0;
        if (kIsDesktop && !_isMobile) {
          heightPercentage = _document!
                  .pages[_pdfViewerController.pageNumber - 1].size.height /
              _pdfPages[_pdfViewerController.pageNumber]!.pageSize.height;
        }
        if (widget.pageLayoutMode == PdfPageLayoutMode.single &&
            _singlePageViewKey.currentState != null) {
          final double greyAreaHeight =
              _singlePageViewKey.currentState!.greyAreaSize / 2;
          if (_viewportConstraints.maxHeight >
              _pdfPages[_pdfViewerController.pageNumber]!.pageSize.height *
                  _pdfViewerController.zoomLevel) {
            _singlePageViewKey.currentState!.jumpOnZoomedDocument(
                _pdfViewerController.pageNumber,
                Offset(xPosition / heightPercentage,
                    yPosition / heightPercentage));
          } else {
            _singlePageViewKey.currentState!.jumpOnZoomedDocument(
                _pdfViewerController.pageNumber,
                Offset(xPosition / heightPercentage,
                    (yPosition + greyAreaHeight) / heightPercentage));
          }
        }
      });
    }
  }

  void _updateScrollDirectionChange(
      Offset initialOffset, int pageIndex, double totalHeight) {
    if (_scrollDirection != _tempScrollDirection ||
        _pageLayoutMode != widget.pageLayoutMode) {
      WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
        _checkMount();
      });
      if (pageIndex == 1 &&
          !_viewportConstraints.biggest.isEmpty &&
          _pdfScrollableStateKey.currentState != null) {
        _offsetBeforeOrientationChange = Offset(
            _pdfScrollableStateKey.currentState!.currentOffset.dx /
                _pdfDimension.width,
            _pdfScrollableStateKey.currentState!.currentOffset.dy /
                _pdfDimension.height);
      } else if (pageIndex == _pdfViewerController.pageCount &&
          _pdfScrollableStateKey.currentState != null) {
        if (_viewportWidth != 0) {
          WidgetsBinding.instance
              .addPostFrameCallback((Duration timeStamp) async {
            _pdfPagesKey[_pdfViewerController.pageNumber]
                ?.currentState
                ?.canvasRenderBox
                ?.updateContextMenuPosition();
            if (_pdfViewerController.zoomLevel <= 1) {
              if (_scrollDirection == PdfScrollDirection.vertical &&
                  widget.pageLayoutMode != PdfPageLayoutMode.single) {
                final dynamic pageOffset =
                    _pdfPages[_pdfViewerController.pageNumber]!.pageOffset;
                _scrollDirectionSwitchOffset = Offset(0, pageOffset);
              } else {
                final dynamic pageOffset =
                    _pdfPages[_pdfViewerController.pageNumber]!.pageOffset;
                _scrollDirectionSwitchOffset = Offset(pageOffset, 0);
              }
            } else if (_pdfScrollableStateKey.currentState != null) {
              if (_scrollDirection == PdfScrollDirection.vertical &&
                  widget.pageLayoutMode != PdfPageLayoutMode.single) {
                final dynamic pageOffset =
                    _pdfPages[_pdfViewerController.pageNumber]!.pageOffset;
                final dynamic calculatedOffsetY = pageOffset +
                    (initialOffset.dy *
                        _pdfPages[_pdfViewerController.pageNumber]!
                            .pageSize
                            .height);
                final dynamic calculatedOffsetX =
                    (_pdfScrollableStateKey.currentState!.currentOffset.dx -
                            _pageOffsetBeforeScrollDirectionChange) *
                        (_pdfPages[_pdfViewerController.pageNumber]!
                                .pageSize
                                .width /
                            _pageSizeBeforeScrollDirectionChange.width);

                _scrollDirectionSwitchOffset =
                    Offset(calculatedOffsetX, calculatedOffsetY);
              } else {
                final dynamic pageOffset =
                    _pdfPages[_pdfViewerController.pageNumber]!.pageOffset;
                final dynamic calculatedOffsetX = pageOffset +
                    (initialOffset.dx *
                        _pdfPages[_pdfViewerController.pageNumber]!
                            .pageSize
                            .width);
                final dynamic calculatedOffsetY =
                    (_pdfScrollableStateKey.currentState!.currentOffset.dy -
                            _pageOffsetBeforeScrollDirectionChange) /
                        (_pageSizeBeforeScrollDirectionChange.height /
                            _pdfPages[_pdfViewerController.pageNumber]!
                                .pageSize
                                .height);

                _scrollDirectionSwitchOffset =
                    Offset(calculatedOffsetX, calculatedOffsetY);
              }
            }
            _isScrollDirectionChange =
                true && _layoutChangeOffset == Offset.zero;
          });
        }
        _tempScrollDirection = _scrollDirection;
        _pageLayoutMode = widget.pageLayoutMode;
      }
    } else if (widget.pageLayoutMode == PdfPageLayoutMode.continuous ||
        widget.pageLayoutMode != PdfPageLayoutMode.single) {
      _pageOffsetBeforeScrollDirectionChange =
          _pdfPages[_pdfViewerController.pageNumber]!.pageOffset;
      _pageSizeBeforeScrollDirectionChange =
          _pdfPages[_pdfViewerController.pageNumber]!.pageSize;
    }
  }

  Size _calculateSize(BoxConstraints constraints, double originalWidth,
      double originalHeight, double newWidth, double newHeight) {
    if (_viewportConstraints.maxWidth > newHeight &&
        !kIsDesktop &&
        _scrollDirection == PdfScrollDirection.horizontal &&
        widget.pageLayoutMode != PdfPageLayoutMode.single) {
      constraints = BoxConstraints.tightFor(
        height: _viewportHeightInLandscape ?? newHeight,
      ).enforce(constraints);
    } else {
      if (widget.pageLayoutMode == PdfPageLayoutMode.single &&
          (!_isMobile || _viewportConstraints.maxWidth > newHeight)) {
        constraints = BoxConstraints.tightFor(
          height: newHeight,
        ).enforce(constraints);
      } else {
        constraints = BoxConstraints.tightFor(
          width: newWidth,
        ).enforce(constraints);
      }
    }

    Size newSize = constraints.constrainSizeAndAttemptToPreserveAspectRatio(
        Size(originalWidth, originalHeight));
    if ((widget.pageLayoutMode == PdfPageLayoutMode.single ||
            widget.scrollDirection == PdfScrollDirection.horizontal &&
                Orientation.portrait == MediaQuery.of(context).orientation) &&
        newSize.height > newHeight) {
      BoxConstraints newConstraints = BoxConstraints(
          maxWidth: _viewportConstraints.maxWidth, maxHeight: newHeight);
      newConstraints = BoxConstraints.tightFor(
        height: newHeight,
      ).enforce(newConstraints);
      newSize = newConstraints.constrainSizeAndAttemptToPreserveAspectRatio(
          Size(originalWidth, originalHeight));
    }

    return newSize;
  }

  void _updateCurrentPageNumber({double currentOffset = 0}) {
    if (currentOffset > 0) {
      _pdfViewerController._pageNumber =
          _pdfScrollableStateKey.currentState?.getPageNumber(currentOffset) ??
              0;
    } else {
      _pdfViewerController.pageCount > 0
          ? _pdfViewerController._pageNumber = 1
          : _pdfViewerController._pageNumber = 0;
    }
    _pageChanged();
    _checkMount();
  }

  void _handleTextSelectionDragStarted() {
    setState(() {
      _panEnabled = false;
    });
  }

  void _handleTextSelectionDragEnded() {
    setState(() {
      _panEnabled = true;
    });
  }

  void _jumpToPage(int pageNumber) {
    if (widget.pageLayoutMode == PdfPageLayoutMode.single) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(pageNumber - 1);
      }
    } else if (_scrollDirection == PdfScrollDirection.horizontal) {
      _pdfScrollableStateKey.currentState
          ?.jumpTo(xOffset: _pdfPages[pageNumber]!.pageOffset);
    } else {
      _pdfScrollableStateKey.currentState
          ?.jumpTo(yOffset: _pdfPages[pageNumber]!.pageOffset);
    }
  }

  void _jumpToBookmark(PdfBookmark? bookmark) {
    if (bookmark != null && _document != null) {
      _clearSelection();
      double heightPercentage;
      double widthPercentage;
      Offset bookmarkOffset;
      PdfPage pdfPage;
      if (bookmark.namedDestination != null) {
        pdfPage = bookmark.namedDestination!.destination!.page;
      } else {
        pdfPage = bookmark.destination!.page;
      }
      final int index = _document!.pages.indexOf(pdfPage) + 1;
      final Size revealedOffset = _pdfPages[index]!.pageSize;
      double yOffset = _pdfPages[index]!.pageOffset;
      final bool isRotatedTo90or270 =
          pdfPage.rotation == PdfPageRotateAngle.rotateAngle90 ||
              pdfPage.rotation == PdfPageRotateAngle.rotateAngle270;
      if (bookmark.namedDestination != null) {
        heightPercentage = bookmark
                .namedDestination!.destination!.page.size.height /
            (isRotatedTo90or270 ? revealedOffset.width : revealedOffset.height);
        widthPercentage = bookmark
                .namedDestination!.destination!.page.size.width /
            (isRotatedTo90or270 ? revealedOffset.height : revealedOffset.width);
        bookmarkOffset = bookmark.namedDestination!.destination!.location;
      } else {
        heightPercentage = bookmark.destination!.page.size.height /
            (isRotatedTo90or270 ? revealedOffset.width : revealedOffset.height);
        widthPercentage = bookmark.destination!.page.size.width /
            (isRotatedTo90or270 ? revealedOffset.height : revealedOffset.width);
        bookmarkOffset = bookmark.destination!.location;
      }
      if (_pdfPagesKey[_pdfViewerController.pageNumber]!.currentState != null &&
          _pdfPagesKey[_pdfViewerController.pageNumber]!
                  .currentState!
                  .canvasRenderBox !=
              null) {
        bookmarkOffset = _pdfPagesKey[_pdfViewerController.pageNumber]!
            .currentState!
            .canvasRenderBox!
            .getRotatedOffset(bookmarkOffset, index - 1, pdfPage.rotation);
      }
      if (kIsDesktop &&
          !_isMobile &&
          widget.pageLayoutMode == PdfPageLayoutMode.continuous) {
        heightPercentage = 1.0;
      }
      yOffset = yOffset + (bookmarkOffset.dy / heightPercentage);
      double xOffset = bookmarkOffset.dx / widthPercentage;
      if (_scrollDirection == PdfScrollDirection.horizontal) {
        if (_pdfViewerController.zoomLevel == 1) {
          xOffset = _pdfPages[index]!.pageOffset;
          yOffset = bookmarkOffset.dy / heightPercentage;
        } else {
          xOffset = _pdfPages[index]!.pageOffset +
              bookmarkOffset.dx / widthPercentage;
          yOffset = bookmarkOffset.dy / heightPercentage;
        }
      }
      if (yOffset > _maxScrollExtent) {
        yOffset = _maxScrollExtent;
      }
      if (widget.pageLayoutMode == PdfPageLayoutMode.single) {
        xOffset = bookmarkOffset.dx / widthPercentage;
        yOffset = bookmarkOffset.dy / heightPercentage;
        _singlePageViewKey.currentState!
            .jumpOnZoomedDocument(index, Offset(xOffset, yOffset));
      } else {
        _pdfScrollableStateKey.currentState
            ?.jumpTo(xOffset: xOffset, yOffset: yOffset);
      }
    }
  }

  bool _clearSelection() {
    return _pdfPagesKey[_pdfViewerController.pageNumber]
            ?.currentState
            ?.canvasRenderBox
            ?.clearSelection() ??
        false;
  }

  int _getPageIndex(double offset) {
    int pageIndex = 1;
    for (int index = 1; index <= _pdfViewerController.pageCount; index++) {
      final double pageStartOffset = _pdfPages[index]!.pageOffset;
      final double pageEndOffset =
          _pdfPages[index]!.pageOffset + _pdfPages[index]!.pageSize.width;
      if (offset >= pageStartOffset && offset < pageEndOffset) {
        pageIndex = index;
      }
    }
    return pageIndex;
  }

  void _handleControllerValueChange({String? property}) {
    if (property == 'jumpToBookmark') {
      if (_pdfPages.isNotEmpty) {
        _jumpToBookmark(_pdfViewerController._pdfBookmark);
      }
    } else if (property == 'zoomLevel') {
      if (_pdfViewerController.zoomLevel > _maxScale) {
        _pdfViewerController.zoomLevel = _maxScale;
      } else if (_pdfViewerController.zoomLevel < _minScale) {
        _pdfViewerController.zoomLevel = _minScale;
      }
      if (widget.pageLayoutMode == PdfPageLayoutMode.continuous) {
        if (_pdfScrollableStateKey.currentState != null) {
          _pdfViewerController._zoomLevel = _pdfScrollableStateKey.currentState!
              .scaleTo(_pdfViewerController.zoomLevel);
          final double previousScale =
              _pdfScrollableStateKey.currentState!.previousZoomLevel;
          final double oldZoomLevel = previousScale;
          final double newZoomLevel = _pdfViewerController._zoomLevel;
          if (newZoomLevel != _previousTiledZoomLevel &&
              (newZoomLevel - _previousTiledZoomLevel).abs() >= 0.25) {
            setState(() {
              _isZoomChanged = true;
              _previousTiledZoomLevel = newZoomLevel;
            });
          }
          if (widget.onZoomLevelChanged != null &&
              previousScale != _pdfViewerController._zoomLevel) {
            if (newZoomLevel != oldZoomLevel) {
              widget.onZoomLevelChanged!(
                  PdfZoomDetails(newZoomLevel, oldZoomLevel));
            }
          }
          PageStorage.of(context)?.writeState(
              context, _pdfViewerController.zoomLevel,
              identifier: 'zoomLevel_${widget.key}');
        }
      } else {
        if (_singlePageViewKey.currentState != null) {
          _pdfViewerController._zoomLevel = _singlePageViewKey.currentState!
              .scaleTo(_pdfViewerController.zoomLevel);
          if (!_singlePageViewKey.currentState!.isJumpOnZoomedDocument) {
            final double previousScale =
                _singlePageViewKey.currentState!.previousZoomLevel;
            final double oldZoomLevel = previousScale;
            final double newZoomLevel = _pdfViewerController._zoomLevel;
            if (newZoomLevel != _previousTiledZoomLevel &&
                (newZoomLevel - _previousTiledZoomLevel).abs() >= 0.25) {
              setState(() {
                _isZoomChanged = true;
                _previousTiledZoomLevel = newZoomLevel;
              });
            }
            if (widget.onZoomLevelChanged != null &&
                previousScale != _pdfViewerController._zoomLevel) {
              if (newZoomLevel != oldZoomLevel) {
                widget.onZoomLevelChanged!(
                    PdfZoomDetails(newZoomLevel, oldZoomLevel));
              }
            }
          }
          PageStorage.of(context)?.writeState(
              context, _pdfViewerController.zoomLevel,
              identifier: 'zoomLevel_${widget.key}');
        }
      }
    } else if (property == 'clearTextSelection') {
      _pdfViewerController._clearTextSelection = _clearSelection();
    } else if (property == 'jumpTo') {
      _clearSelection();
      if (widget.pageLayoutMode == PdfPageLayoutMode.single) {
        if (_previousHorizontalOffset !=
                _pdfViewerController._horizontalOffset &&
            _pageController.hasClients) {
          _jumpToPage(_getPageIndex(_pdfViewerController._horizontalOffset));
          _previousHorizontalOffset = _pdfViewerController._horizontalOffset;
        }
        if (_singlePageViewKey.currentState != null) {
          _singlePageViewKey.currentState!
              .jumpTo(yOffset: _pdfViewerController._verticalOffset);
        }
      } else if (!_pdfDimension.isEmpty) {
        _pdfScrollableStateKey.currentState?.jumpTo(
            xOffset: _pdfViewerController._horizontalOffset,
            yOffset: _pdfViewerController._verticalOffset);
      }
    } else if (property == 'pageNavigate' &&
        _pdfViewerController._pageNavigator != null) {
      _clearSelection();
      switch (_pdfViewerController._pageNavigator!.option) {
        case Navigation.jumpToPage:
          if (_pdfViewerController._pageNavigator!.index! > 0 &&
              _pdfViewerController._pageNavigator!.index! <=
                  _pdfViewerController.pageCount) {
            _jumpToPage(_pdfViewerController._pageNavigator!.index!);
          }
          break;
        case Navigation.firstPage:
          _jumpToPage(1);
          break;
        case Navigation.lastPage:
          if (_pdfViewerController.pageNumber !=
              _pdfViewerController.pageCount) {
            _jumpToPage(_pdfViewerController.pageCount);
          }
          break;
        case Navigation.previousPage:
          if (_pdfViewerController.pageNumber > 1) {
            _jumpToPage(_pdfViewerController.pageNumber - 1);
          }
          break;
        case Navigation.nextPage:
          if (_pdfViewerController.pageNumber !=
              _pdfViewerController.pageCount) {
            _jumpToPage(_pdfViewerController.pageNumber + 1);
          }
          break;
      }
    } else if (property == 'searchText') {
      _isSearchStarted = true;
      _matchedTextPageIndices.clear();
      _pdfViewerController._pdfTextSearchResult
          ._removeListener(_handleTextSearch);
      if (kIsWeb) {
        _textCollection = _pdfTextExtractor?.findText(
          <String>[_pdfViewerController._searchText],
          searchOption: _pdfViewerController._textSearchOption,
        );
        if (_textCollection!.isEmpty) {
          _pdfViewerController._pdfTextSearchResult._currentOccurrenceIndex = 0;
          _pdfViewerController._pdfTextSearchResult._totalSearchTextCount = 0;
          _pdfViewerController._pdfTextSearchResult._updateResult(false);
        } else {
          _pdfViewerController._pdfTextSearchResult._currentOccurrenceIndex =
              _getInstanceInPage(_pdfViewerController.pageNumber);
          if (_pdfPages.isNotEmpty) {
            _jumpToSearchInstance();
          }
          _pdfViewerController._pdfTextSearchResult._totalSearchTextCount =
              _textCollection!.length;
          _pdfViewerController._pdfTextSearchResult._updateResult(true);
        }
        _pdfViewerController._pdfTextSearchResult
            ._addListener(_handleTextSearch);
        setState(() {});
      } else {
        if (_isTextExtractionCompleted) {
          final String searchText =
              _pdfViewerController._searchText.toLowerCase();
          _extractedTextCollection.forEach((int key, String value) {
            if (value.contains(searchText)) {
              _matchedTextPageIndices.add(key);
            }
          });
          _performTextSearch();
        }
      }
    }
  }

  Future<void> _performTextSearch() async {
    _pdfViewerController._pdfTextSearchResult._addListener(_handleTextSearch);
    setState(() {});
    _pdfViewerController._pdfTextSearchResult.clear();
    final ReceivePort receivePort = ReceivePort();
    receivePort.listen((dynamic message) {
      if (message is SendPort) {
        message.send(<dynamic>[
          receivePort.sendPort,
          _pdfTextExtractor,
          _pdfViewerController._searchText,
          _pdfViewerController._textSearchOption,
          _matchedTextPageIndices,
        ]);
      } else if (message is List<MatchedItem>) {
        _textCollection!.addAll(message);
        if (_textCollection!.isNotEmpty &&
            _pdfViewerController._pdfTextSearchResult.totalInstanceCount == 0) {
          _pdfViewerController._pdfTextSearchResult._updateResult(true);
          _pdfViewerController._pdfTextSearchResult._currentOccurrenceIndex = 1;
          _isPageChanged = false;
          if (_pdfPages.isNotEmpty) {
            _jumpToSearchInstance();
          }
          _pdfViewerController._pdfTextSearchResult._totalSearchTextCount =
              _textCollection!.length;
        }
        if (_textCollection!.isNotEmpty) {
          _pdfViewerController._pdfTextSearchResult._totalSearchTextCount =
              _textCollection!.length;
        }
      } else if (message is String) {
        if (_textCollection!.isEmpty) {
          _pdfViewerController._pdfTextSearchResult._currentOccurrenceIndex = 0;
          _pdfViewerController._pdfTextSearchResult._totalSearchTextCount = 0;
          _pdfViewerController._pdfTextSearchResult._updateResult(false);
        }
        _pdfViewerController._pdfTextSearchResult
            ._updateSearchCompletedStatus(true);
      }
    });
    _textSearchIsolate =
        await Isolate.spawn(_findTextAsync, receivePort.sendPort);
  }

  static Future<void> _findTextAsync(SendPort sendPort) async {
    final ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    final searchDetails = await receivePort.first;
    final SendPort replyPort = searchDetails[0];
    for (int i = 0; i < searchDetails[4].length; i++) {
      final List<MatchedItem> result = searchDetails[1].findText(<String>[
        searchDetails[2],
      ], startPageIndex: searchDetails[4][i], searchOption: searchDetails[3]);
      replyPort.send(result);
    }
    replyPort.send('SearchCompleted');
  }

  void _killTextSearchIsolate() {
    if (_textSearchIsolate != null) {
      _textSearchIsolate?.kill(priority: Isolate.immediate);
    }
  }

  int _getInstanceInPage(int pageNumber, {bool lookForFirst = true}) {
    int? instance = 0;
    if (lookForFirst) {
      instance = _jumpToNextInstance(pageNumber) ??
          _jumpToPreviousInstance(pageNumber);
    } else {
      instance = _jumpToPreviousInstance(pageNumber) ??
          _jumpToNextInstance(pageNumber);
    }
    return instance ?? 1;
  }

  int? _jumpToNextInstance(int pageNumber) {
    for (int i = 0; i < _textCollection!.length; i++) {
      if (_textCollection![i].pageIndex + 1 >= pageNumber) {
        return i + 1;
      }
    }
    return null;
  }

  int? _jumpToPreviousInstance(int pageNumber) {
    for (int i = _textCollection!.length - 1; i > 0; i--) {
      if (_textCollection![i].pageIndex + 1 <= pageNumber) {
        return i + 1;
      }
    }
    return null;
  }

  void _jumpToSearchInstance({bool isNext = true}) {
    if (_isPageChanged) {
      _updateSearchInstance(isNext: isNext);
      _isPageChanged = false;
    }
    const int searchInstanceTopMargin = 20;
    final int currentInstancePageIndex = _textCollection![
                _pdfViewerController._pdfTextSearchResult.currentInstanceIndex -
                    1]
            .pageIndex +
        1;
    Offset topOffset = Offset.zero;

    if (_pdfPagesKey[_pdfViewerController.pageNumber]
            ?.currentState
            ?.canvasRenderBox !=
        null) {
      topOffset = _pdfPagesKey[_pdfViewerController.pageNumber]!
          .currentState!
          .canvasRenderBox!
          .getRotatedTextBounds(
              _textCollection![_pdfViewerController
                          ._pdfTextSearchResult.currentInstanceIndex -
                      1]
                  .bounds,
              currentInstancePageIndex - 1,
              _document!.pages[currentInstancePageIndex - 1].rotation)
          .topLeft;
    }
    final double heightPercentage = (kIsDesktop &&
            !_isMobile &&
            !_isOverflowed &&
            widget.pageLayoutMode == PdfPageLayoutMode.continuous)
        ? 1
        : _document!.pages[currentInstancePageIndex - 1].size.height /
            _pdfPages[currentInstancePageIndex]!.pageSize.height;

    final double widthPercentage = (kIsDesktop &&
            !_isMobile &&
            !_isOverflowed &&
            widget.pageLayoutMode == PdfPageLayoutMode.continuous)
        ? 1
        : _document!.pages[currentInstancePageIndex - 1].size.width /
            _pdfPages[currentInstancePageIndex]!.pageSize.width;

    double searchOffsetX = topOffset.dx / widthPercentage;

    double searchOffsetY = (_pdfPages[currentInstancePageIndex]!.pageOffset +
            (topOffset.dy / heightPercentage)) -
        searchInstanceTopMargin;

    if (_scrollDirection == PdfScrollDirection.horizontal) {
      searchOffsetX = _pdfPages[currentInstancePageIndex]!.pageOffset +
          topOffset.dx / widthPercentage;
      searchOffsetY =
          (topOffset.dy / heightPercentage) - searchInstanceTopMargin;
    }
    final Offset offset =
        _pdfScrollableStateKey.currentState?.currentOffset ?? Offset.zero;
    final Rect viewport = Rect.fromLTWH(
        offset.dx,
        offset.dy - searchInstanceTopMargin,
        _viewportConstraints.biggest.width / _pdfViewerController.zoomLevel,
        _viewportConstraints.biggest.height / _pdfViewerController.zoomLevel);
    final Offset singleLayoutOffset =
        _singlePageViewKey.currentState?.currentOffset ?? Offset.zero;
    final Rect singleLayoutViewport = Rect.fromLTWH(
        singleLayoutOffset.dx,
        singleLayoutOffset.dy,
        _viewportConstraints.biggest.width / _pdfViewerController.zoomLevel,
        _viewportConstraints.biggest.height / _pdfViewerController.zoomLevel);
    if (widget.pageLayoutMode == PdfPageLayoutMode.single) {
      if (!singleLayoutViewport.contains(Offset(
              topOffset.dx / widthPercentage,
              (topOffset.dy / heightPercentage) +
                  _singlePageViewKey.currentState!.greyAreaSize)) ||
          currentInstancePageIndex != _pdfViewerController.pageNumber) {
        _singlePageViewKey.currentState!.jumpOnZoomedDocument(
            currentInstancePageIndex,
            Offset(topOffset.dx / widthPercentage,
                topOffset.dy / heightPercentage));
      }
      WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
        if (_isPageChanged) {
          _isPageChanged = false;
        }
      });
    } else {
      if (_pdfScrollableStateKey.currentState != null &&
          !viewport.contains(Offset(searchOffsetX, searchOffsetY))) {
        _pdfViewerController.jumpTo(
            xOffset: searchOffsetX, yOffset: searchOffsetY);
        WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
          if (_isPageChanged) {
            _isPageChanged = false;
          }
        });
      }
    }
  }

  void _handleTextSearch({String? property}) {
    if (_pdfViewerController._pdfTextSearchResult.hasResult) {
      if (property == 'nextInstance') {
        setState(() {
          _pdfViewerController._pdfTextSearchResult
              ._currentOccurrenceIndex = _pdfViewerController
                      ._pdfTextSearchResult.currentInstanceIndex <
                  _pdfViewerController._pdfTextSearchResult._totalInstanceCount
              ? _pdfViewerController._pdfTextSearchResult.currentInstanceIndex +
                  1
              : 1;
          _jumpToSearchInstance();
        });
      } else if (property == 'previousInstance') {
        setState(() {
          _pdfViewerController._pdfTextSearchResult._currentOccurrenceIndex =
              _pdfViewerController._pdfTextSearchResult.currentInstanceIndex > 1
                  ? _pdfViewerController
                          ._pdfTextSearchResult.currentInstanceIndex -
                      1
                  : _pdfViewerController
                      ._pdfTextSearchResult.totalInstanceCount;
          _jumpToSearchInstance(isNext: false);
        });
      }
    }
    if (property == 'clear') {
      setState(() {
        if (!kIsWeb) {
          _killTextSearchIsolate();
        }

        _isSearchStarted = false;
        _textCollection = <MatchedItem>[];

        _pdfViewerController._pdfTextSearchResult
            ._updateSearchCompletedStatus(false);
        _pdfViewerController._pdfTextSearchResult._currentOccurrenceIndex = 0;
        _pdfViewerController._pdfTextSearchResult._totalSearchTextCount = 0;
        _pdfViewerController._pdfTextSearchResult._updateResult(false);
        _pdfPagesKey[_pdfViewerController.pageNumber]
            ?.currentState
            ?.focusNode
            .requestFocus();
      });
      return;
    }
  }

  void _handlePdfOffsetChanged(Offset offset) {
    if (!_isSearchStarted) {
      _pdfPagesKey[_pdfViewerController.pageNumber]
          ?.currentState
          ?.focusNode
          .requestFocus();
    }
    if (widget.pageLayoutMode == PdfPageLayoutMode.continuous) {
      if (_scrollDirection == PdfScrollDirection.horizontal) {
        _updateCurrentPageNumber(currentOffset: offset.dx);
      } else {
        _updateCurrentPageNumber(currentOffset: offset.dy);
      }
    }
    if (widget.pageLayoutMode == PdfPageLayoutMode.single &&
        _pageController.hasClients) {
      _pdfViewerController._scrollPositionX = _pageController.offset;
    } else {
      _pdfViewerController._scrollPositionX = offset.dx.abs();
    }
    _pdfViewerController._scrollPositionY = offset.dy.abs();
  }
}

class PdfViewerController extends ChangeNotifier with _ValueChangeNotifier {
  double _zoomLevel = 1;

  int _currentPageNumber = 0;

  int _totalPages = 0;

  String _searchText = '';

  TextSearchOption? _textSearchOption;

  set _pageNumber(int num) {
    _currentPageNumber = num;
    notifyListeners();
  }

  set _pageCount(int pageCount) {
    _totalPages = pageCount;
    _notifyPropertyChangedListeners(property: 'pageCount');
  }

  PdfBookmark? _pdfBookmark;

  final PdfTextSearchResult _pdfTextSearchResult = PdfTextSearchResult();

  double _verticalOffset = 0.0;

  double _horizontalOffset = 0.0;

  Pagination? _pageNavigator;

  bool _clearTextSelection = false;

  double _scrollPositionX = 0.0;

  double _scrollPositionY = 0.0;

  Offset get scrollOffset => Offset(_scrollPositionX, _scrollPositionY);

  double get zoomLevel => _zoomLevel;

  set zoomLevel(double newValue) {
    if (_zoomLevel == newValue) {
      return;
    }
    _zoomLevel = newValue;
    _notifyPropertyChangedListeners(property: 'zoomLevel');
  }

  int get pageNumber {
    return _currentPageNumber;
  }

  int get pageCount {
    return _totalPages;
  }

  void jumpToBookmark(PdfBookmark bookmark) {
    _pdfBookmark = bookmark;
    _notifyPropertyChangedListeners(property: 'jumpToBookmark');
  }

  void jumpTo({double xOffset = 0.0, double yOffset = 0.0}) {
    _horizontalOffset = xOffset;
    _verticalOffset = yOffset;
    _notifyPropertyChangedListeners(property: 'jumpTo');
  }

  void jumpToPage(int pageNumber) {
    _pageNavigator = Pagination(Navigation.jumpToPage, index: pageNumber);
    _notifyPropertyChangedListeners(property: 'pageNavigate');
  }

  void previousPage() {
    _pageNavigator = Pagination(Navigation.previousPage);
    _notifyPropertyChangedListeners(property: 'pageNavigate');
  }

  void nextPage() {
    _pageNavigator = Pagination(Navigation.nextPage);
    _notifyPropertyChangedListeners(property: 'pageNavigate');
  }

  void firstPage() {
    _pageNavigator = Pagination(Navigation.firstPage);
    _notifyPropertyChangedListeners(property: 'pageNavigate');
  }

  void lastPage() {
    _pageNavigator = Pagination(Navigation.lastPage);
    _notifyPropertyChangedListeners(property: 'pageNavigate');
  }

  PdfTextSearchResult searchText(String searchText,
      {TextSearchOption? searchOption}) {
    _searchText = searchText;
    _textSearchOption = searchOption;
    _notifyPropertyChangedListeners(property: 'searchText');
    return _pdfTextSearchResult;
  }

  bool clearSelection() {
    _notifyPropertyChangedListeners(property: 'clearTextSelection');
    return _clearTextSelection;
  }

  void _reset() {
    _zoomLevel = 1.0;
    _currentPageNumber = 0;
    _totalPages = 0;
    _verticalOffset = 0.0;
    _horizontalOffset = 0.0;
    _searchText = '';
    _pageNavigator = null;
    _pdfBookmark = null;
    _notifyPropertyChangedListeners();
  }
}

class PdfTextSearchResult extends ChangeNotifier with _ValueChangeNotifier {
  int _currentInstanceIndex = 0;

  int _totalInstanceCount = 0;

  bool _hasResult = false;

  bool _isSearchCompleted = false;

  set _currentOccurrenceIndex(int num) {
    _currentInstanceIndex = num;
    notifyListeners();
  }

  int get currentInstanceIndex {
    return _currentInstanceIndex;
  }

  set _totalSearchTextCount(int totalInstanceCount) {
    _totalInstanceCount = totalInstanceCount;
    notifyListeners();
  }

  int get totalInstanceCount {
    return _totalInstanceCount;
  }

  void _updateResult(bool hasResult) {
    _hasResult = hasResult;
    notifyListeners();
  }

  bool get hasResult {
    return _hasResult;
  }

  void _updateSearchCompletedStatus(bool isSearchCompleted) {
    _isSearchCompleted = isSearchCompleted;
    notifyListeners();
  }

  bool get isSearchCompleted {
    return _isSearchCompleted;
  }

  void nextInstance() {
    _notifyPropertyChangedListeners(property: 'nextInstance');
  }

  void previousInstance() {
    _notifyPropertyChangedListeners(property: 'previousInstance');
  }

  void clear() {
    _notifyPropertyChangedListeners(property: 'clear');
  }
}

class _ValueChangeNotifier {
  late _PdfControllerListener _listener;
  final ObserverList<_PdfControllerListener> _listeners =
      ObserverList<_PdfControllerListener>();

  void _addListener(_PdfControllerListener listener) {
    _listeners.add(listener);
  }

  void _removeListener(_PdfControllerListener listener) {
    _listeners.remove(listener);
  }

  @protected
  void _notifyPropertyChangedListeners({String? property}) {
    for (_listener in _listeners) {
      _listener(property: property);
    }
  }
}
