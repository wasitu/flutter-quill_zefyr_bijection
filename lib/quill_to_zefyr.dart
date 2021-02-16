import 'package:quill_delta/quill_delta.dart';

Delta convertIterableToDelta(Iterable list, {bool initialize = true}) {
  try {
    var finalZefyrData = [];
    list.toList().forEach((quillNode) {
      var finalZefyrNode = {};

      // insert
      var quillInsertNode = quillNode["insert"];
      final isLine = (quillInsertNode as String)?.contains('\n') ?? false;

      // reatain
      var quillRetainNode = quillNode["retain"];
      final isRetain = quillRetainNode != null;

      final isBlock = isLine || isRetain;

      // attributes
      var quillAttributesNode = quillNode["attributes"];
      if (quillAttributesNode != null) {
        var finalZefyrAttributes = {};
        if (quillAttributesNode is Map) {
          quillAttributesNode.keys.forEach((attrKey) {
            if (["b", "i", "block", "heading", "a", "checkbox", "indent"]
                .contains(attrKey)) {
              finalZefyrAttributes[attrKey] = quillAttributesNode[attrKey];
            } else if (["background", "align"].contains(attrKey)) {
              // not sure how to implement
            } else {
              if (attrKey == "bold")
                finalZefyrAttributes["b"] =
                    quillAttributesNode[attrKey] ?? false;
              else if (attrKey == "italic")
                finalZefyrAttributes["i"] = true;
              else if (attrKey == "blockquote")
                finalZefyrAttributes["block"] = "quote";
              else if (attrKey == "code-block")
                finalZefyrAttributes["block"] = "code";
              else if (attrKey == "embed" &&
                  quillAttributesNode[attrKey]["type"] == "dots")
                finalZefyrAttributes["embed"] = {"type": "hr"};
              else if (attrKey == "link")
                finalZefyrAttributes["a"] =
                    quillAttributesNode[attrKey] ?? "n/a";
              else if (attrKey == "header" && isBlock)
                finalZefyrAttributes["heading"] = quillAttributesNode[attrKey];
              else if (attrKey == "list" &&
                  quillAttributesNode[attrKey] == "bullet" &&
                  isBlock)
                finalZefyrAttributes["block"] = "ul";
              else if (attrKey == "list" &&
                  quillAttributesNode[attrKey] == "ordered" &&
                  isBlock)
                finalZefyrAttributes["block"] = "ol";
              else if (attrKey == "list" &&
                  quillAttributesNode[attrKey] == "checked" &&
                  isBlock)
                finalZefyrAttributes["checkbox"] = "checked";
              else if (attrKey == "list" &&
                  quillAttributesNode[attrKey] == "unchecked" &&
                  isBlock)
                finalZefyrAttributes["checkbox"] = "unchecked";
              else if (attrKey == "id" &&
                  quillAttributesNode[attrKey] != null) {
                finalZefyrAttributes[attrKey] = quillAttributesNode[attrKey];
              } else if (attrKey == "timestamp" &&
                  quillAttributesNode[attrKey] != null) {
                finalZefyrAttributes[attrKey] = quillAttributesNode[attrKey];
              } else if (!initialize && quillAttributesNode[attrKey] == null) {
                if (attrKey == "list") {
                  finalZefyrAttributes["block"] = null;
                  finalZefyrAttributes["checkbox"] = null;
                } else if (attrKey == "header") {
                  finalZefyrAttributes["heading"] = null;
                }
              } else {
                print("ignoring " + attrKey);
              }
            }
          });
          if (finalZefyrAttributes.keys.length > 0)
            finalZefyrNode["attributes"] = finalZefyrAttributes;
        }
      }

      if (quillInsertNode != null) {
        if (quillInsertNode is Map && quillInsertNode.containsKey("image")) {
          var finalAttributes = {
            "embed": {"type": "image", "source": quillInsertNode["image"]}
          };
          finalZefyrNode["insert"] = String.fromCharCode(0x200b);
          finalZefyrNode["attributes"] = finalAttributes;
          finalZefyrData.add(finalZefyrNode);
        } else if (quillInsertNode is Map) {
          print("ignoring " + quillInsertNode.toString());
        } else {
          finalZefyrNode["insert"] = quillInsertNode;
          finalZefyrData.add(finalZefyrNode);
        }
      }

      if (quillRetainNode != null) {
        if (initialize && finalZefyrNode["attributes"] != null) {
          finalZefyrNode["attributes"]
              .removeWhere((key, value) => value == null);
          if (finalZefyrNode["attributes"].isNotEmpty) {
            finalZefyrNode["insert"] = "\n";
            finalZefyrData.add(finalZefyrNode);
          }
        }
        if (!initialize && quillRetainNode != null) {
          finalZefyrNode["retain"] = quillRetainNode;
          finalZefyrData.add(finalZefyrNode);
        }
      }

      // delete
      var quillDeleteNode = quillNode["delete"];
      if (!initialize && quillDeleteNode != null) {
        finalZefyrNode["delete"] = quillDeleteNode;
        finalZefyrData.add(finalZefyrNode);
      }
    });
    return Delta.fromJson(finalZefyrData);
  } catch (e) {
    throw e;
  }
}
