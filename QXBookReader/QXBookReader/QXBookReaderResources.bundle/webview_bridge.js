
/// 在页面加载成功后执行该方法
function __qx_book_init_html() {
    // 内容间隙
    document.body.style = 'padding: 15px 15px 15px 15px !important;';
    
//    __qx_book_set_highlight('5/0', 28, 34, '__qx_book_highlight_yellow');

    
}

function __qx_book_remove_class(e, cls) {
    if (__qx_book_has_class(e, cls)) {
        var reg = new RegExp('(\\s|^)' + cls + '(\\s|$)');
        e.className = e.className.replace(reg,' ');
    }
}
function __qx_book_set_theme(cls) {
    var e = document.documentElement;
    __qx_book_remove_class(e, "__qx_book_theme_gray");
    __qx_book_remove_class(e, "__qx_book_theme_night");
    __qx_book_remove_class(e, "__qx_book_theme_papper");
    __qx_book_remove_class(e, "__qx_book_theme_flower");
    __qx_book_remove_class(e, "__qx_book_theme_grass");
    __qx_book_add_class(e, cls);
}
function __qx_book_set_font_size(cls) {
    var e = document.documentElement;
    __qx_book_remove_class(e, "__qx_book_font_size_10");
    __qx_book_remove_class(e, "__qx_book_font_size_12");
    __qx_book_remove_class(e, "__qx_book_font_size_14");
    __qx_book_remove_class(e, "__qx_book_font_size_16");
    __qx_book_remove_class(e, "__qx_book_font_size_18");
    __qx_book_remove_class(e, "__qx_book_font_size_20");
    __qx_book_remove_class(e, "__qx_book_font_size_22");
    __qx_book_remove_class(e, "__qx_book_font_size_24");
    __qx_book_remove_class(e, "__qx_book_font_size_26");
    __qx_book_remove_class(e, "__qx_book_font_size_28");
    __qx_book_remove_class(e, "__qx_book_font_size_30");
    __qx_book_add_class(e, cls);
}
function __qx_book_set_line_space_rate(cls) {
    var e = document.documentElement;
    __qx_book_remove_class(e, "__qx_book_line_space_rate_1_2");
    __qx_book_remove_class(e, "__qx_book_line_space_rate_1_4");
    __qx_book_remove_class(e, "__qx_book_line_space_rate_1_6");
    __qx_book_add_class(e, cls);
}

function __qx_book_has_class(e, cls) {
    return !!e.className.match(new RegExp('(\\s|^)'+cls+'(\\s|$)'));
}
function __qx_book_add_class(e, cls) {
    if (!__qx_book_has_class(e, cls)) {
        e.className += " " + cls;
    }
}

/// 获取选中的文本
function __qx_book_get_selected_text() {
    return window.getSelection().toString();
}

/// 获取元素对应的offset
function __qx_book_get_element_offset(el, pageMode) {
    if (pageMode === 'page') {
        return document.body.clientWidth * Math.floor(el.offsetTop / window.innerHeight);
    }
    return el.offsetTop;
}
/// 根据元素id获取元素对应的offset
function __qx_book_get_element_offset_by_id(id, pageMode) {
    var el = document.getElementById(id);
    if (!el) {
        return;
    }
    return __qx_book_get_element_offset(el, pageMode);
}

/// 获取显示的第一个元素的索引信息（索引+备注）
function __qx_book_get_first_showing_element_index_path_info(offset) {
    var match = (els, indexes) => {
        if (els && els.length > 0) {
            for (var i = 0; i < els.length; i++) {
                var el = els[i];
                if (el.offsetTop !== undefined && offset <= el.offsetTop) {
                    indexes.push(i);
                    return { indexes, content: el.innerHTML };
                } else {
                    var _indexes = indexes.slice();
                    _indexes.push(i);
                    var info = match(el.children, _indexes);
                    if (info) {
                        return info;
                    }
                }
            }
        }
        return undefined;
    }
    var info = match(document.body.children, []);
    if (info) {
        return JSON.stringify({
            indexPath: info.indexes.join('/'),
            content: info.content
        });
    }
    return undefined;
}
function __qx_book_get_element_by_index_path(indexPath) {
    var indexes = indexPath.split('/');
    var els = document.body.children;
    var el;
    var i = 0;
    while (i < indexes.length) {
        el = els[indexes[i]];
        els = el.children
        i += 1;
    }
    return el;
}
function __qx_book_get_element_offset_by_index_path(indexPath, pageMode) {
    var el = __qx_book_get_element_by_index_path(indexPath);
    if (el) {
        return __qx_book_get_element_offset(el, pageMode);
    }
    return undefined;
}


/// 获取元素的rect
function __qx_book_get_element_rect(el) {
    var rect = el.getBoundingClientRect();
    return "{{" + rect.left + "," + rect.top + "}, {" + rect.width + "," + rect.height + "}}";
}

/// 获取选中的rect
function __qx_book_get_selection_rect() {
    var el = window.getSelection().getRangeAt(0);
    return __qx_book_get_element_rect(el);
}

var __qx_book_current_highlight;
function __qx_book_update_selection_range_for_highlight() {
    var selection =  window.getSelection()
    var range = selection.getRangeAt(0);
  //   var startNode = range.startContainer;
  //   var startOffset = range.startOffset;
  //   var endNode = range.endContainer;
  //   var endOffset = range.endOffset;
  //   selection.removeAllRanges();
  //   var range = document.createRange();
  //  range.setStart(startNode, startOffset);
  //  if (startNode === endNode) {
  //      range.setEnd(startNode, endOffset);
  //  } else {
  //      range.setEnd(startNode, startNode.length);
  //  }
  //   selection.addRange(range);
    return range;
}

function __qx_book_check_or_update_selection_for_highlight() {
    var range = __qx_book_update_selection_range_for_highlight();
    return __qx_book_get_element_rect(range);
}

function __qx_book_set_highlight(indexPath, startOffset, endOffset, cls) {
    var node = __qx_book_get_element_by_index_path(indexPath);
    if (!node) {
        return;
    }
    var selection =  window.getSelection()
    selection.removeAllRanges();
    var range = document.createRange();
//    range.selectNode(node);
    
//    range.setStart(node, startOffset);

//    range.setEnd(node, endOffset);

    
    
    selection.addRange(range);

    var selectionContents = range.extractContents();
    var el = document.createElement("highlight");
    el.appendChild(selectionContents);
//    el.setAttribute("id", id);
    el.setAttribute("onclick", "__qx_book_action_highlight(this);");
    el.setAttribute("class", cls);
    range.insertNode(el);
}

function __qx_book_set_selection_highlight(id, cls) {
    var range = __qx_book_update_selection_range_for_highlight();
    // var startOffset = range.startOffset;
    // var endOffset = range.endOffset;
    
    // var _el = range.commonAncestorContainer;
    // if (_el.nodeType != 1) {
    //     _el = _el.parentNode;
    // }
    // var indexPath = __qx_book_get_element_index_path(_el);


    var _range;
    var _highlight;
    var fragment = range.cloneContents();
    for (var i = 0; i < fragment.childNodes.length; i++) {
      var node = fragment.childNodes[i];
      if (node === range.startContainer) {
        alert(1);
        _range = document.createRange();
        _range.setStart(range.startContainer, range.startOffset);
        _range.setEnd(range.startContainer, range.startContainer.length);
        _highlight = __qx_book_generate_highlight(id, cls);
        _highlight.appendChild(_range.extractContents());
        _range.insertNode(_highlight);
      } else if (node === range.endContainer) {
        alert(2);
        _range = document.createRange();
        _range.setStart(range.endContainer, 0);
        _range.setEnd(range.endContainer, range.endOffset);
        var _highlight = __qx_book_generate_highlight(id, cls);
        _highlight.appendChild(_range.extractContents());
        _range.insertNode(_highlight);
      } else {
        alert(3);
        _range = document.createRange();
        _range.selectNode(node);
        var _highlight = __qx_book_generate_highlight(id, cls);
        _highlight.appendChild(_range.extractContents());
        _range.insertNode(_highlight);
      }
    }

        
    // var selectionContents = range.extractContents();

    // var highlight = __qx_book_generate_highlight(id, cls);
    // highlight.appendChild(selectionContents);
    // range.insertNode(highlight);
    
    // return JSON.stringify({
    //     indexPath: indexPath.join('/'),
    //     startOffset,
    //     endOffset
    // });
    
}

function __qx_book_generate_highlight(id, cls) {
  var el = document.createElement("highlight");
  el.setAttribute("id", id);
  el.setAttribute("onclick", "__qx_book_action_highlight(this);");
  el.setAttribute("class", cls);
  return el;
}

function __qx_book_action_highlight(el) {
    event.stopPropagation();
    var highlightRect = __qx_book_get_element_rect(el);
    __qx_book_current_highlight = el;
    window.location = "qxbookhighlight://" + encodeURIComponent(highlightRect);
}

function __qx_book_get_element_index_path(el) {
    var match = (els, indexes) => {
        if (els && els.length > 0) {
            for (var i = 0; i < els.length; i++) {
                if (els[i] === el) {
                    indexes.push(i);
                    return indexes;
                } else {
                    var _indexes = indexes.slice();
                    _indexes.push(i);
                    var res = match(els[i].children, _indexes);
                    if (res) {
                        return res;
                    }
                }
            }
        }
        return undefined;
    }
    return match(document.body.children, []);
}

function __qx_book_remove_highlight_by_id(id) {
    var el = document.getElementById(id);
    el.outerHTML = el.innerHTML;
}
function __qx_book_remove_current_highlight() {
    var el = __qx_book_current_highlight;
    if (el) {
        el.outerHTML = el.innerHTML;
    }
}

function __qx_book_get_html() {
    return document.documentElement.outerHTML;
}

