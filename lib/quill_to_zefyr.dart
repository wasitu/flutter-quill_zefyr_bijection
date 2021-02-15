import 'package:quill_delta/quill_delta.dart';

Delta convertIterableToDelta(Iterable list, {bool initialize = true}) {
  try {
    var finalZefyrData = [];
    list.toList().forEach((quillNode) {
      var finalZefyrNode = {};

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
              else if (attrKey == "header")
                finalZefyrAttributes["heading"] = quillAttributesNode[attrKey];
              else if (attrKey == "link")
                finalZefyrAttributes["a"] =
                    quillAttributesNode[attrKey] ?? "n/a";
              else if (attrKey == "list" &&
                  quillAttributesNode[attrKey] == "bullet")
                finalZefyrAttributes["block"] = "ul";
              else if (attrKey == "list" &&
                  quillAttributesNode[attrKey] == "ordered")
                finalZefyrAttributes["block"] = "ol";
              else if (attrKey == "list" &&
                  quillAttributesNode[attrKey] == "checked")
                finalZefyrAttributes["checkbox"] = "checked";
              else if (attrKey == "list" &&
                  quillAttributesNode[attrKey] == "unchecked")
                finalZefyrAttributes["checkbox"] = "unchecked";
              else if (attrKey == "list" &&
                  quillAttributesNode[attrKey] == null) {
                finalZefyrAttributes["block"] = null;
                finalZefyrAttributes["checkbox"] = null;
              } else if (attrKey == "id" &&
                  quillAttributesNode[attrKey] != null) {
                finalZefyrAttributes[attrKey] = quillAttributesNode[attrKey];
              } else if (attrKey == "timestamp" &&
                  quillAttributesNode[attrKey] != null) {
                finalZefyrAttributes[attrKey] = quillAttributesNode[attrKey];
              } else {
                print("ignoring " + attrKey);
              }
            }
          });
          if (finalZefyrAttributes.keys.length > 0)
            finalZefyrNode["attributes"] = finalZefyrAttributes;
        }
      }

      // insert
      var quillInsertNode = quillNode["insert"];
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

      // reatain
      var quillRetainNode = quillNode["retain"];
      if (!initialize && quillRetainNode != null) {
        finalZefyrNode["retain"] = quillRetainNode;
        finalZefyrData.add(finalZefyrNode);
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
