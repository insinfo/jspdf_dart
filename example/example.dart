import 'dart:html' as html;
import 'dart:js_util';
import 'package:jspdf/jspdf.dart';

void main() async {
  final svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 300">
  <text x="20" y="20" font-size="20" font-family="Roboto" font-style="normal" font-weight="normal">Hello, svg!</text>
  <g transform="matrix(1, 0, 0, 1, 30 30)">
    <circle r="32" cx="35" cy="65" fill="#F00" opacity="0.5"/>
    <circle r="32" cx="65" cy="65" fill="#0F0" opacity="0.5"/>
    <circle r="32" cx="50" cy="35" fill="#00F" opacity="0.5"/>
  </g>
</svg>''';

  final svgDoc = html.DomParser().parseFromString(svg, 'image/svg+xml');

  final width = 500;
  final height = 300;

  await jsPdfAddFont('roboto_regular.ttf', 'Roboto', 'normal', 'normal');

  final doc = JsPDF(width > height ? 'l' : 'p', 'pt', [width, height]);

  await doc.addSvgVector(svgDoc.documentElement!,
      {'width': width, 'height': height, 'x': 20, 'y': 30});

  doc.setFontSize(30);
  doc.setFont('Roboto', 'normal');
  doc.text('Hello PDF!', 200, 30);

  doc.addPage();

  doc.setFillColor(52, 255, 39);
  doc.circle(120, 120, 30, 'F');
  doc.setFillColor(52, 90, 39);
  doc.rect(120, 20, 10, 10, 'F');
  doc.setFillColor(52, 20, 39);
  doc.triangle(100, 100, 50, 50, 100, 20, 'F');

  doc.setTextColor(255, 0, 0);

  doc.addPage();

  var data = [
    ['SL.No', 'Product Name', 'Price', 'Model'],
    [1, 'I-phone', 75000, '2021'],
    [2, 'Realme', 25000, '2022'],
    [3, 'Oneplus', 30000, '2021'],
  ];

  var y = 10;
  doc.setLineWidth(2);
  doc.text('Product detailed report', 30, y = y + 30);
  doc.autoTable(jsify({
    'body': data,
    'startY': 70,
    'theme': 'grid',
  }));

  html.document
      .getElementById('pdf-iframe')
      ?.setAttribute('src', doc.output('datauristring'));
}
