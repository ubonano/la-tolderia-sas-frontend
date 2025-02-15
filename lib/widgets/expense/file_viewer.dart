import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:get/get.dart';
import '../../controllers/pdf_viewer_controller.dart';

class FileViewer extends StatelessWidget {
  final String fileUrl;
  final String fileName;

  const FileViewer({
    super.key,
    required this.fileUrl,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.5,
      ),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(4, 0),
            blurRadius: 8.0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: _buildViewer(),
      ),
    );
  }

  Widget _buildViewer() {
    if (fileName.toLowerCase().endsWith('.pdf')) {
      return _buildPdfViewer();
    } else {
      return _buildImageViewer();
    }
  }

  Widget _buildPdfViewer() {
    // Reemplazamos el widget PDF por uno stateful, que actualiza su estilo sin redibujar el viewer.
    return PdfViewerWidget(fileUrl: fileUrl);
  }

  Widget _buildImageViewer() {
    return Image.network(
      fileUrl,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return const Center(child: Text('Error al cargar la imagen'));
      },
    );
  }
}

// Nuevo widget stateful para el visor PDF en web.
class PdfViewerWidget extends StatefulWidget {
  final String fileUrl;
  const PdfViewerWidget({Key? key, required this.fileUrl}) : super(key: key);

  @override
  _PdfViewerWidgetState createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  late final String viewId;

  @override
  void initState() {
    super.initState();
    viewId = 'pdf-viewer-${DateTime.now().millisecondsSinceEpoch}';
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int _) {
      final container = html.DivElement()..id = viewId;
      final iframe = html.IFrameElement()
        ..src = 'https://mozilla.github.io/pdf.js/web/viewer.html?file=${Uri.encodeComponent(widget.fileUrl)}'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'fullscreen';
      container.append(iframe);
      return container;
    });

    // Escuchar cambios en el controlador sin redibujar el widget entero
    ever(PdfViewerController.to.isDisabled, (bool disabled) {
      final container = html.document.getElementById(viewId);
      if (container != null) {
        container.style.pointerEvents = disabled ? 'none' : 'auto';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: viewId);
  }
}
