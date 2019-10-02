local ribbon = require()

local class = ribbon.require "class"

local object = ribbon.reqpath "${CLASS}/object/object"
local Object = object.Object

local ArgStack = ribbon.reqpath("${CLASS}/object/pobjects/functionobject").FunctionObject.ArgumentList
local PFunctionObject = ribbon.reqpath("${CLASS}/object/pobjects/pfunctionobject").PFunctionObject

local NodeListObject = ribbon.reqpath("${loadingplugin.html.object}/nodelistobject").NodeListObject

local nodeobject = ...

local NodeObject = {}
nodeobject.NodeObject = NodeObject

NodeObject.cparents = {Object} --TODO: extend EventObject instead
function NodeObject:__call(cache)
    Object.__call(self, cache)
end

function NodeObject:installFields()
    self:setraw("__proto__", self.cache.get("Object"))
    
    self:setrawm(
        "ELEMENT_NODE", 1,
        "ATTRIBUTE_NODE", 2,
        "TEXT_NODE", 3,
        "CDATA_SECTION_NODE", 4,
        "ENTITY_REFERENCE_NODE", 5,
        "ENTITY_NODE", 6,
        "PROCESSING_INSTRUCTION_NODE", 7,
        "COMMENT_NODE", 8,
        "DOCUMENT_NODE", 9,
        "DOCUMENT_TYPE_NODE", 10,
        "DOCUMENT_FRAGMENT_NODE", 11,
        "NOTATION_NODE", 12,
    )
    //nodeType
    //nodeName
    
    //baseURI
    
    //isConnected
    //ownerDocument
    //getRootNode
    //parentNode
    //parentElement
    self:setraw("hasChildNodes", class.new(PFunctionObject, function()
        return self:getraw("childNodes"):get("length") > 0
    end))
    self:setraw("childNodes", class.new(NodeListObject))
    self:setproperty("firstchild", {
        get = function()
            return self:getraw("childNodes"):getraw("item"):invoke(class.new(ArgumentList), self.cache.get("Window")) --TODO: Pass Window as this
        end
    })
    //firstChild
    //lastChild
    //previousSibling
    //nextSibling
    
    //nodeValue
    //textContent
    //normalize
    
    //cloneNode
    //isEqualNode
    //isSameNode
    
    self:setrawm(
        "DOCUMENT_POSITION_DISCONNECTED", 0x01,
        "DOCUMENT_POSITION_PRECEDING", 0x02,
        "DOCUMENT_POSITION_FOLLOWING", 0x04,
        "DOCUMENT_POSITION_CONTAINS", 0x08,
        "DOCUMENT_POSITION_CONTAINED_BY", 0x10,
        "DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC", 0x20,
    )
    //compareDocumentPosition
    //contains
    
    //lookupPrefix
    //lookupNamespaceURI
    //isDefaultNamespace
    
    //insertBefore
    //appendChild
    //replaceChild
    //removeChild
    
end