//window.jspdf
@JS()
library jspdf;

import 'dart:async';
import 'dart:html';
import 'dart:js_util';

import 'package:js/js.dart';

/// add custom font to jsPDF
Future<void> jsPdfAddFont(
    String src, String name, String style, String weight) async {
  //https://rawgit.com/MrRio/jsPDF/master/fontconverter/fontconverter.html
  final dataBase64 = await urlContentToDataUri2(src);
  final filename = src.split('\\').removeLast().split('/').removeLast();
  eventsPush([
    'addFonts',
    allowInteropCaptureThis((JsPDF self, s) {
      self.addFileToVFS(filename, dataBase64);
      self.addFont(filename, name, style, weight); //weight
    })
  ]);
}

@anonymous
@JS()
class JsPDFSvgOptions {
  external num get x;
  external set x(num value);
  external num get y;
  external set y(num value);
  external num get width;
  external set width(num value);
  external num get height;
  external set height(num value);

  external factory JsPDFSvgOptions({
    required num x,
    required num y,
    required num width,
    required num height,
  });
}

//jsPDF.API.events.push(['addFonts', callAddFont]);
@JS('window.jspdf.jsPDF.API.events.push')
external eventsPush(List list);

Future<String?> urlContentToDataUri(String url) async {
  final completer = Completer<String?>();
  Blob blob = await HttpRequest.request(url, responseType: 'blob')
      .then((request) => request.response);

  final reader = FileReader();
  reader.onLoad.listen((event) {
    var data = (reader.result as String?);
    data = data?.substring(data.indexOf(',') + 1);
    completer.complete(data);
  });
  reader.readAsDataUrl(blob);
  return completer.future;
}

Future<String?> urlContentToDataUri2(String url) async {
  final completer = Completer<String?>();
  Blob blob = await window.fetch(url).then((response) => response.blob());

  final reader = FileReader();
  reader.onLoad.listen((event) {
    var data = (reader.result as String?);
    data = data?.substring(data.indexOf(',') + 1);
    completer.complete(data);
  });
  reader.readAsDataUrl(blob);
  return completer.future;
}

/// orientation, unit, format
/// const doc = new jsPDF('p', 'mm', [width, height]);
@JS('window.jspdf.jsPDF')
class JsPDF {
  ///  Landscape export, 2×4 inches
  /// final doc = new jsPDF(jsify({
  ///   'orientation': "landscape",
  ///   'unit': "in",
  ///   'format': [4, 2]
  /// }));
  external JsPDF(orientation, unit, List format);

  /// [filename]	The filename including extension.
  /// [options] An Object with additional options, possible options: 'returnPromise'.
  external JsPDF save([String filename, options]);

  /// [format]	String/List
  /// The format of the new page. Can be:
  /// a0 - a10
  /// b0 - b10
  /// c0 - c10
  /// dl
  /// letter
  /// government-letter
  /// legal
  /// junior-legal
  /// ledger
  /// tabloid
  /// credit-card
  ///
  /// Default is "a4". If you want to use your own format just pass instead of one of the above predefined formats the size as an number-array, e.g. [595.28, 841.89]
  /// [orientation]	 Orientation of the new page. Possible values are "portrait" or "landscape" (or shortcuts "p" (Default), "l").
  external JsPDF addPage([dynamic format, String orientation]);

  /// Parses SVG XML and saves it as an image into the PDF.
  ///
  /// Depends on canvas-element and canvg.
  ///
  ///  [svg] SVG data as text.
  ///  [x] X-coordinate against the left edge of the page (in units declared at the inception of the PDF document).
  ///  [y] Y-coordinate against the upper edge of the page (in units declared at the inception of the PDF document).
  ///  [w] Width of the SVG image (in units declared at the inception of the PDF document).
  ///  [h] Height of the SVG image (in units declared at the inception of the PDF document).
  ///  [alias] Alias of the SVG image (if used multiple times).
  ///  [compression] Compression of the generated JPEG, can have the values 'NONE', 'FAST', 'MEDIUM', and 'SLOW'.
  ///  [rotation] Rotation of the image in degrees (0-359).
  ///
  /// `Return` A JsPDF instance.
  external JsPDF addSvgAsImage(String svg, num x, num y, num w, num h,
      String alias, String compression, num rotation);

  /// Parses SVG XML and converts only some of the SVG elements into PDF elements.
  ///
  /// Supports:
  /// - paths
  ///
  /// @param svgtext SVG data as text.
  /// @param x X-coordinate against the left edge of the page (in units declared at the inception of the PDF document).
  /// @param y Y-coordinate against the upper edge of the page (in units declared at the inception of the PDF document).
  /// @param w Width of the SVG (in units declared at the inception of the PDF document).
  /// @param h Height of the SVG (in units declared at the inception of the PDF document).
  ///
  /// @return A jsPDF instance.
  external JsPDF addSvg(String svgtext, num x, num y, num w, num h);

  /// [jsMapOptions] JsObject/JsPDFSvgOptions { x: x,   y: y,  width: width,  height: height   }
  /// [svgElement]  html svg element
  /// from
  external svg(Element svgElement, jsMapOptions);
  //external svg(svgElement, jsMapOptions);

  /// [size] Sets font size for upcoming text elements.
  external JsPDF setFontSize(num size);

  /// [fontName]Font name or family. Example: "times".
  /// [fontStyle]	Font style or variant. Example: "italic"
  external JsPDF setFont(String fontName, String fontStyle);

  /// [text]	String | List	of strings to be added to the page. Each line is shifted one line down per font, spacing settings declared before this call.
  /// [x]	number Coordinate (in units declared at inception of PDF document) against left edge of the page.
  /// [y]	number Coordinate (in units declared at inception of PDF document) against upper edge of the page.
  /// [options] JsObject Collection of settings signaling how the text must be encoded.
  external JsPDF text(text, num x, num y, [options, transform]);

  /// Add a file to the vFS
  ///
  /// @name addFileToVFS
  /// @function
  /// @param {string} filename The name of the file which should be added.
  /// @param {string} filecontent The content of the file.
  /// @returns {jsPDF}
  /// @example
  /// doc.addFileToVFS("someFile.txt", "BADFACE1");
  external JsPDF addFileToVFS(filename, filecontent);

  /// Add a custom font to the current instance.
  ///
  /// @param {string} postScriptName PDF specification full name for the font.
  /// @param {string} id PDF-document-instance-specific label assinged to the font.
  /// @param {string} fontStyle Style of the Font.
  /// @param {number | string} fontWeight Weight of the Font.
  /// @param {Object} encoding Encoding_name-to-Font_metrics_object mapping.
  /// @function
  /// @instance
  /// @memberof jsPDF#
  /// @name addFont
  /// @returns {string} fontId
  /// encoding = encoding || 'Identity-H';
  external addFont(postScriptName, fontName, fontStyle, fontWeight, [encoding]);

  /// [format] string format of file if filetype-recognition fails, e.g. 'JPEG'
  /// [alias]	string	alias of the image (if used multiple times)
  /// [compression]	string compression of the generated JPEG, can have the values 'NONE', 'FAST', 'MEDIUM' and 'SLOW'
  /// [rotation]	number	rotation of the image in degrees (0-359)
  external addImage(
      imageData, String format, num x, num y, num width, num height,
      [alias, compression, rotation]);

  /// Generates the PDF document.
  /// If type argument is undefined, output is raw body of resulting PDF returned as a string.
  external output([String? type, options]);

  /**
     * Adds an circle to PDF.
     *
     * @param {number} x Coordinate (in units declared at inception of PDF document) against left edge of the page.
     * @param {number} y Coordinate (in units declared at inception of PDF document) against upper edge of the page.
     * @param {number} r Radius (in units declared at inception of PDF document).
     * @param {string} style A string specifying the painting style or null.  Valid styles include: 'S' [default] - stroke, 'F' - fill,  and 'DF' (or 'FD') -  fill then stroke. A null value postpones setting the style so that a shape may be composed using multiple method calls. The last drawing method call used to define the shape should not have a null style argument.
     * @function
     * @instance
     * @returns {jsPDF}
     * @memberof jsPDF#
     * @name circle
     */
  external circle([x, y, r, style]);

  /**
     * Adds a rectangle to PDF.
     *
     * @param {number} x Coordinate (in units declared at inception of PDF document) against left edge of the page.
     * @param {number} y Coordinate (in units declared at inception of PDF document) against upper edge of the page.
     * @param {number} w Width (in units declared at inception of PDF document).
     * @param {number} h Height (in units declared at inception of PDF document).
     * @param {string} style A string specifying the painting style or null.  Valid styles include: 'S' [default] - stroke, 'F' - fill,  and 'DF' (or 'FD') -  fill then stroke. A null value postpones setting the style so that a shape may be composed using multiple method calls. The last drawing method call used to define the shape should not have a null style argument.
     * @function
     * @instance
     * @returns {jsPDF}
     * @memberof jsPDF#
     * @name rect
     */
  external rect([x, y, w, h, style]);

  /**
     * Adds an ellipse to PDF.
     *
     * @param {number} x Coordinate (in units declared at inception of PDF document) against left edge of the page.
     * @param {number} y Coordinate (in units declared at inception of PDF document) against upper edge of the page.
     * @param {number} rx Radius along x axis (in units declared at inception of PDF document).
     * @param {number} ry Radius along y axis (in units declared at inception of PDF document).
     * @param {string} style A string specifying the painting style or null.  Valid styles include: 'S' [default] - stroke, 'F' - fill,  and 'DF' (or 'FD') -  fill then stroke. A null value postpones setting the style so that a shape may be composed using multiple method calls. The last drawing method call used to define the shape should not have a null style argument.
     * @function
     * @instance
     * @returns {jsPDF}
     * @memberof jsPDF#
     * @name ellipse
     */
  external ellise(x, y, rx, ry, style);

  /**
     * Deletes a page from the PDF.
     * @name deletePage
     * @memberof jsPDF#
     * @function
     * @param {number} targetPage
     * @instance
     * @returns {jsPDF}
     */
  external deletePage(number);

  /**
     * Sets the fill color for upcoming elements.
     *
     * Depending on the number of arguments given, Gray, RGB, or CMYK
     * color space is implied.
     *
     * When only ch1 is given, "Gray" color space is implied and it
     * must be a value in the range from 0.00 (solid black) to to 1.00 (white)
     * if values are communicated as String types, or in range from 0 (black)
     * to 255 (white) if communicated as Number type.
     * The RGB-like 0-255 range is provided for backward compatibility.
     *
     * When only ch1,ch2,ch3 are given, "RGB" color space is implied and each
     * value must be in the range from 0.00 (minimum intensity) to to 1.00
     * (max intensity) if values are communicated as String types, or
     * from 0 (min intensity) to to 255 (max intensity) if values are communicated
     * as Number types.
     * The RGB-like 0-255 range is provided for backward compatibility.
     *
     * When ch1,ch2,ch3,ch4 are given, "CMYK" color space is implied and each
     * value must be a in the range from 0.00 (0% concentration) to to
     * 1.00 (100% concentration)
     *
     * Because JavaScript treats fixed point numbers badly (rounds to
     * floating point nearest to binary representation) it is highly advised to
     * communicate the fractional numbers as String types, not JavaScript Number type.
     *
     * @param {Number|String} ch1 Color channel value or {string} ch1 color value in hexadecimal, example: '#FFFFFF'.
     * @param {Number} ch2 Color channel value.
     * @param {Number} ch3 Color channel value.
     * @param {Number} ch4 Color channel value.
     *
     * @function
     * @instance
     * @returns {jsPDF}
     * @memberof jsPDF#
     * @name setFillColor
     */
  external setFillColor([ch1, ch2, ch3, ch4]);

  /**
     * Sets the text color for upcoming elements.
     *
     * Depending on the number of arguments given, Gray, RGB, or CMYK
     * color space is implied.
     *
     * When only ch1 is given, "Gray" color space is implied and it
     * must be a value in the range from 0.00 (solid black) to to 1.00 (white)
     * if values are communicated as String types, or in range from 0 (black)
     * to 255 (white) if communicated as Number type.
     * The RGB-like 0-255 range is provided for backward compatibility.
     *
     * When only ch1,ch2,ch3 are given, "RGB" color space is implied and each
     * value must be in the range from 0.00 (minimum intensity) to to 1.00
     * (max intensity) if values are communicated as String types, or
     * from 0 (min intensity) to to 255 (max intensity) if values are communicated
     * as Number types.
     * The RGB-like 0-255 range is provided for backward compatibility.
     *
     * When ch1,ch2,ch3,ch4 are given, "CMYK" color space is implied and each
     * value must be a in the range from 0.00 (0% concentration) to to
     * 1.00 (100% concentration)
     *
     * Because JavaScript treats fixed point numbers badly (rounds to
     * floating point nearest to binary representation) it is highly advised to
     * communicate the fractional numbers as String types, not JavaScript Number type.
     *
     * @param {Number|String} ch1 Color channel value or {string} ch1 color value in hexadecimal, example: '#FFFFFF'.
     * @param {Number} ch2 Color channel value.
     * @param {Number} ch3 Color channel value.
     * @param {Number} ch4 Color channel value.
     *
     * @function
     * @instance
     * @returns {jsPDF}
     * @memberof jsPDF#
     * @name setTextColor
     */
  external setTextColor([ch1, ch2, ch3, ch4]);

  /**
     * Starts a new pdf form object, which means that all consequent draw calls target a new independent object
     * until {@link endFormObject} is called. The created object can be referenced and drawn later using
     * {@link doFormObject}. Nested form objects are possible.
     * x, y, width, height set the bounding box that is used to clip the content.
     *
     * @param {number} x
     * @param {number} y
     * @param {number} width
     * @param {number} height
     * @param {Matrix} matrix The matrix that will be applied to convert the form objects coordinate system to
     * the parent's.
     * @function
     * @returns {jsPDF}
     * @memberof jsPDF#
     * @name beginFormObject
     */
  external beginFormObject(x, y, width, height, matrix);
  /**
     * 
     * @name clip
     * @function
     * @instance
     * @param {string} rule Only possible value is 'evenodd'
     * @returns {jsPDF}
     * @memberof jsPDF#
     * @description All .clip() after calling drawing ops with a style argument of null.
     */
  external clip(rule);

  /**
    * Draws the specified form object by referencing to the respective pdf XObject created with
    * {@link API.beginFormObject} and {@link endFormObject}.
    * The location is determined by matrix.
    *
    * @param {String} key The key to the form object.
    * @param {Matrix} matrix The matrix applied before drawing the form object.
    * @function
    * @returns {jsPDF}
    * @memberof jsPDF#
    * @name doFormObject
    */
  external doFormObject(key, matrix);

  /**
     * Completes and saves the form object. 
     * @param {String} key The key by which this form object can be referenced.
     * @function
     * @returns {jsPDF}
     * @memberof jsPDF#
     * @name endFormObject
     */
  external endFormObject(key);

  /**
     * Get global value of CharSpace.
     *
     * @function
     * @instance
     * @returns {number} charSpace
     * @memberof jsPDF#
     * @name getCharSpace
     */
  external getCharSpace();

  /**
     * @name getCreationDate
     * @memberof jsPDF#
     * @function
     * @instance
     * @param {Object} type
     * @returns {Object}
     */
  external getCreationDate(type);

  /**
     *  Gets the stroke color for upcoming elements.
     *
     * @function
     * @instance
     * @returns {string} colorAsHex
     * @memberof jsPDF#
     * @name getDrawColor
     */
  external getStrokeColor();

  /**
     * @name insertPage
     * @memberof jsPDF#
     * 
     * @function 
     * @instance
     * @param {Object} beforePage
     * @returns {jsPDF}
     */
  external insertPage(beforePage);

  /**
     * Draw a line on the current page.
     *
     * @name line
     * @function 
     * @instance
     * @param {number} x1
     * @param {number} y1
     * @param {number} x2
     * @param {number} y2
     * @param {string} style A string specifying the painting style or null.  Valid styles include: 'S' [default] - stroke, 'F' - fill,  and 'DF' (or 'FD') -  fill then stroke. A null value postpones setting the style so that a shape may be composed using multiple method calls. The last drawing method call used to define the shape should not have a null style argument. default: 'S'
     * @returns {jsPDF}
     * @memberof jsPDF#
     */
  external line([x1, y1, x2, y2, style]);
  /**
     * Adds series of curves (straight lines or cubic bezier curves) to canvas, starting at `x`, `y` coordinates.
     * All data points in `lines` are relative to last line origin.
     * `x`, `y` become x1,y1 for first line / curve in the set.
     * For lines you only need to specify [x2, y2] - (ending point) vector against x1, y1 starting point.
     * For bezier curves you need to specify [x2,y2,x3,y3,x4,y4] - vectors to control points 1, 2, ending point. All vectors are against the start of the curve - x1,y1.
     *
     * @example .lines([[2,2],[-2,2],[1,1,2,2,3,3],[2,1]], 212,110, [1,1], 'F', false) // line, line, bezier curve, line
     * @param {Array} lines Array of *vector* shifts as pairs (lines) or sextets (cubic bezier curves).
     * @param {number} x Coordinate (in units declared at inception of PDF document) against left edge of the page.
     * @param {number} y Coordinate (in units declared at inception of PDF document) against upper edge of the page.
     * @param {number} scale (Defaults to [1.0,1.0]) x,y Scaling factor for all vectors. Elements can be any floating number Sub-one makes drawing smaller. Over-one grows the drawing. Negative flips the direction.
     * @param {string} style A string specifying the painting style or null.  Valid styles include: 'S' [default] - stroke, 'F' - fill,  and 'DF' (or 'FD') -  fill then stroke. A null value postpones setting the style so that a shape may be composed using multiple method calls. The last drawing method call used to define the shape should not have a null style argument.
     * @param {boolean} closed If true, the path is closed with a straight line from the end of the last curve to the starting point.
     * @function
     * @instance
     * @returns {jsPDF}
     * @memberof jsPDF#
     * @name lines
     */
  external lines([lines, x, y, scale, style, closed]);

  /**
     * Similar to {@link API.lines} but all coordinates are interpreted as absolute coordinates instead of relative.
     * @param {Array<Object>} lines An array of {op: operator, c: coordinates} object, where op is one of "m" (move to), "l" (line to)
     * "c" (cubic bezier curve) and "h" (close (sub)path)). c is an array of coordinates. "m" and "l" expect two, "c"
     * six and "h" an empty array (or undefined).
     * @param {String=} style  The style. Deprecated!
     * @param {String=} patternKey The pattern key for the pattern that should be used to fill the path. Deprecated!
     * @param {(Matrix|PatternData)=} patternData The matrix that transforms the pattern into user space, or an object that
     * will modify the pattern on use. Deprecated!
     * @function
     * @returns {jsPDF}
     * @memberof jsPDF#
     * @name path
     */
  external path(lines, style, patternKey, patternData);

  /**
     * Adds a rectangle with rounded corners to PDF.
     *
     * @param {number} x Coordinate (in units declared at inception of PDF document) against left edge of the page.
     * @param {number} y Coordinate (in units declared at inception of PDF document) against upper edge of the page.
     * @param {number} w Width (in units declared at inception of PDF document).
     * @param {number} h Height (in units declared at inception of PDF document).
     * @param {number} rx Radius along x axis (in units declared at inception of PDF document).
     * @param {number} ry Radius along y axis (in units declared at inception of PDF document).
     * @param {string} style A string specifying the painting style or null.  Valid styles include: 'S' [default] - stroke, 'F' - fill,  and 'DF' (or 'FD') -  fill then stroke. A null value postpones setting the style so that a shape may be composed using multiple method calls. The last drawing method call used to define the shape should not have a null style argument.
     * @function
     * @instance
     * @returns {jsPDF}
     * @memberof jsPDF#
     * @name roundedRect
     */
  external roundedRect(x, y, w, h, rx, ry, style);

  /**
     * Adds a triangle to PDF.
     *
     * @param {number} x1 Coordinate (in units declared at inception of PDF document) against left edge of the page.
     * @param {number} y1 Coordinate (in units declared at inception of PDF document) against upper edge of the page.
     * @param {number} x2 Coordinate (in units declared at inception of PDF document) against left edge of the page.
     * @param {number} y2 Coordinate (in units declared at inception of PDF document) against upper edge of the page.
     * @param {number} x3 Coordinate (in units declared at inception of PDF document) against left edge of the page.
     * @param {number} y3 Coordinate (in units declared at inception of PDF document) against upper edge of the page.
     * @param {string} style A string specifying the painting style or null.  Valid styles include: 'S' [default] - stroke, 'F' - fill,  and 'DF' (or 'FD') -  fill then stroke. A null value postpones setting the style so that a shape may be composed using multiple method calls. The last drawing method call used to define the shape should not have a null style argument.
     * @function
     * @instance
     * @returns {jsPDF}
     * @memberof jsPDF#
     * @name triangle
     */
  external triangle(x1, y1, x2, y2, x3, y3, style);
  /**
     * @name setFileId
     * @memberof jsPDF#
     * @function
     * @instance
     * @param {string} value GUID.
     * @returns {jsPDF}
     */
  external setFileId(value);

  /**
     * Sets the stroke color for upcoming elements.
     *
     * Depending on the number of arguments given, Gray, RGB, or CMYK
     * color space is implied.
     *
     * When only ch1 is given, "Gray" color space is implied and it
     * must be a value in the range from 0.00 (solid black) to to 1.00 (white)
     * if values are communicated as String types, or in range from 0 (black)
     * to 255 (white) if communicated as Number type.
     * The RGB-like 0-255 range is provided for backward compatibility.
     *
     * When only ch1,ch2,ch3 are given, "RGB" color space is implied and each
     * value must be in the range from 0.00 (minimum intensity) to to 1.00
     * (max intensity) if values are communicated as String types, or
     * from 0 (min intensity) to to 255 (max intensity) if values are communicated
     * as Number types.
     * The RGB-like 0-255 range is provided for backward compatibility.
     *
     * When ch1,ch2,ch3,ch4 are given, "CMYK" color space is implied and each
     * value must be a in the range from 0.00 (0% concentration) to to
     * 1.00 (100% concentration)
     *
     * Because JavaScript treats fixed point numbers badly (rounds to
     * floating point nearest to binary representation) it is highly advised to
     * communicate the fractional numbers as String types, not JavaScript Number type.
     *
     * @param {Number|String} ch1 Color channel value or {string} ch1 color value in hexadecimal, example: '#FFFFFF'.
     * @param {Number} ch2 Color channel value.
     * @param {Number} ch3 Color channel value.
     * @param {Number} ch4 Color channel value.
     *
     * @function
     * @instance
     * @returns {jsPDF}
     * @memberof jsPDF#
     * @name setDrawColor
     */
  external setStrokeColor(ch1, ch2, ch3, ch4);

  /**
     * Returns an object - a tree of fontName to fontStyle relationships available to
     * active PDF document.
     *
     * @public
     * @function
     * @instance
     * @returns {Object} Like {'times':['normal', 'italic', ... ], 'arial':['normal', 'bold', ... ], ... }
     * @memberof jsPDF#
     * @name getFontList
     */
  external getFontList();

  /**
     * Gets the fontsize for upcoming text elements.
     *
     * @function
     * @instance
     * @returns {number}
     * @memberof jsPDF#
     * @name getFontSize
     */
  external getFontSize();

  /**
     * Switches font style or variant for upcoming text elements,
     * while keeping the font face or family same.
     * See output of jsPDF.getFontList() for possible font names, styles.
     *
     * @param {string} style Font style or variant. Example: "italic".
     * @function
     * @instance
     * @returns {jsPDF}
     * @memberof jsPDF#
     * @deprecated
     * @name setFontStyle
     */
  external setFontStyle(style);

  /**
     * Saves the current graphics state ("pushes it on the stack"). It can be restored by {@link restoreGraphicsState}
     * later. Here, the general pdf graphics state is meant, also including the current transformation matrix,
     * fill and stroke colors etc.
     * @function
     * @returns {jsPDF}
     * @memberof jsPDF#
     * @name saveGraphicsState
     */
  external saveGraphicsState();

  /**
     * Adds (and transfers the focus to) new page to the PDF document.
     * @function
     * @instance
     * @returns {jsPDF}
     *
     * @memberof jsPDF#
     * @name setPage
     * @param {number} page Switch the active page to the page number specified.
     * @example
     * doc = jsPDF()
     * doc.addPage()
     * doc.addPage()
     * doc.text('I am on page 3', 10, 10)
     * doc.setPage(1)
     * doc.text('I am on page 1', 10, 10)
     */
  external setPage();

  /**
     * Sets line width for upcoming lines.
     *
     * @param {number} width Line width (in units declared at inception of PDF document).
     * @function
     * @instance
     * @returns {jsPDF}
     * @memberof jsPDF#
     * @name setLineWidth
     */
  external setLineWidth(width);
  /// from https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.25/jspdf.plugin.autotable.min.js
  /// https://github.com/simonbengtsson/jsPDF-AutoTable
  external autoTable(options);
}

extension JsPdfExtension on JsPDF {
  /// extension to add SVG as Vector in PDF
  /// from https://raw.githack.com/yWorks/svg2pdf.js/master/dist/svg2pdf.umd.min.j
  Future addSvgVector(Element src, Map<String, dynamic> options) async {
    return await promiseToFuture(svg(src, jsify(options)));
  }
}
