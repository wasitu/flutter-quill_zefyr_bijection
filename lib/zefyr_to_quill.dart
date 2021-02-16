import 'dart:convert';

import 'package:quill_delta/quill_delta.dart';

String convertIterableToQuillJSON(Delta list) {
  try {
    var finalZefyrData = [];
    list.toList().forEach((operation) {
      var finalZefyrNode = {};

      var quillInsertNode = operation.data;
      var quillAttributesNode = operation.attributes;
      if (quillAttributesNode != null) {
        var finalZefyrAttributes = {};

        quillAttributesNode.keys.forEach((attrKey) {
          if (attrKey == "b")
            finalZefyrAttributes["bold"] = true;
          else if (attrKey == "i")
            finalZefyrAttributes["italic"] = true;
          else if (attrKey == "a")
            finalZefyrAttributes["link"] =
                quillAttributesNode[attrKey] ?? "n/a";
          else if (attrKey == "block" &&
              quillAttributesNode[attrKey] == "quote")
            finalZefyrAttributes["blockquote"] = true;
          else if (attrKey == "embed" &&
              quillAttributesNode[attrKey] == "type" &&
              quillAttributesNode[attrKey]["type"] == "hr")
            finalZefyrAttributes["embed"] = {"type": "dots"};
          else if (attrKey == "embed" &&
              quillAttributesNode[attrKey] == "type" &&
              quillAttributesNode[attrKey]["type"] == "image") {
            finalZefyrNode["insert"] = quillAttributesNode[attrKey]["source"];
          } else if (attrKey == "heading")
            finalZefyrAttributes["header"] = quillAttributesNode[attrKey];
          else if (attrKey == "block" && quillAttributesNode[attrKey] == "ul")
            finalZefyrAttributes["list"] = "bullet";
          else if (attrKey == "block" && quillAttributesNode[attrKey] == "ol")
            finalZefyrAttributes["list"] = "ordered";
          else if (attrKey == "block" && quillAttributesNode[attrKey] == null)
            finalZefyrAttributes["list"] = null;
          else if (attrKey == "checkbox" &&
              quillAttributesNode[attrKey] == "checked")
            finalZefyrAttributes["list"] = "checked";
          else if (attrKey == "checkbox" &&
              quillAttributesNode[attrKey] == "unchecked")
            finalZefyrAttributes["list"] = "unchecked";
          else if (attrKey == "checkbox" &&
              quillAttributesNode[attrKey] == null)
            finalZefyrAttributes["list"] = null;
          else {
            print("ignoring " + attrKey);
          }
        });
        if (finalZefyrAttributes.keys.length > 0)
          finalZefyrNode["attributes"] = finalZefyrAttributes;
      }
      if (operation.isInsert && quillInsertNode != null) {
        finalZefyrNode["insert"] = quillInsertNode;
        finalZefyrData.add(finalZefyrNode);
      } else if (operation.isRetain) {
        finalZefyrNode['retain'] = operation.value;
        finalZefyrData.add(finalZefyrNode);
      } else if (operation.isDelete) {
        finalZefyrNode['delete'] = operation.value;
        finalZefyrData.add(finalZefyrNode);
      }
    });
    return jsonEncode({"ops": finalZefyrData});
  } catch (e) {
    throw e;
  }
}
