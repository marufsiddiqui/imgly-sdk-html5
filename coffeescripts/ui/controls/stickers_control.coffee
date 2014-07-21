###
  ImglyKit
  Copyright (c) 2013-2014 img.ly
###

List    = require "./base/list.coffee"
Vector2 = require "../../math/vector2.coffee"
Rect    = require "../../math/rect.coffee"

class UIControlsStickers extends List
  singleOperation: true
  displayButtons: true
  hasCanvasControls: true
  cssClassIdentifier: "sticker"

  ###
    @param {imglyUtil} app
    @param {imglyUtil.UI} ui
  ###
  constructor: (@app, @ui, @controls) ->
    super

    @operationClass = require "../../operations/draw_image.coffee"

    @listItems = [
      {
        name: "Heart"
        cssClass: "sticker"
        method: "useSticker"
        arguments: ["stickers/heart-icon.png"]
        default: true
      },
      {
        name: "NyanCat"
        cssClass: "nyanCat"
        method: "useSticker"
        arguments: ["stickers/nyan-cat.png"]
      }
    ]

  ###
    Update input position
  ###
  updateCanvasControls: ->
    canvasWidth  = @canvasControlsContainer.width()
    canvasHeight = @canvasControlsContainer.height()

  ###
    @param {jQuery.Object} canvasControlsContainer
  ###
  setupCanvasControls: (@canvasControlsContainer) ->
    @stickerContainer = $("<div>")
      .addClass(ImglyKit.classPrefix + "canvas-sticker-container")
      .appendTo @canvasControlsContainer

    #
    # Size buttons
    #
    @stickerSizeButtonsContainer = $("<div>")
      .addClass(ImglyKit.classPrefix + "canvas-sticker-size-container")
      .appendTo @stickerContainer

    for control in ["Smaller", "Bigger"]
      @["stickerSize#{control}Button"] = $("<div>")
        .addClass(
          ImglyKit.classPrefix + "canvas-sticker-size-" + control.toLowerCase()
        )
        .appendTo @stickerSizeButtonsContainer

      @["stickerSize#{control}Button"].on "click", @["onStickersize#{control}Click"]

    #
    # Crosshair / anchor control
    #
    @crosshair = $("<div>")
      .addClass(ImglyKit.classPrefix + "canvas-crosshair " + ImglyKit.classPrefix + "canvas-sticker-crosshair")
      .appendTo @stickerContainer

    @handleCrosshair()

  ###
    Move the text input around by dragging the crosshair
  ###
  handleCrosshair: ->
    canvasRect = new Rect(0, 0, @canvasControlsContainer.width(), @canvasControlsContainer.height())

    minimumWidth  = 50
    minimumHeight = 50

    minContainerPosition = new Vector2(0, 0)
    maxContainerPosition = new Vector2(canvasRect.width - minimumWidth, canvasRect.height - minimumHeight)

    @crosshair.mousedown (e) =>
      # We need the initial as well as the updated mouse position
      initialMousePosition = new Vector2(e.clientX, e.clientY)
      currentMousePosition = new Vector2().copy initialMousePosition

      # We need the initial as well as the updated container position
      initialContainerPosition = new Vector2(@stickerContainer.position().left, @stickerContainer.position().top)
      currentContainerPosition = new Vector2().copy initialContainerPosition

      $(document).mousemove (e) =>
        currentMousePosition.set e.clientX, e.clientY

        # mouse difference = current mouse position - initial mouse position
        mousePositionDifference = new Vector2()
          .copy(currentMousePosition)
          .substract(initialMousePosition)

        # updated container position = initial container position - mouse difference
        currentContainerPosition
          .copy(initialContainerPosition)
          .add(mousePositionDifference)
          .clamp(minContainerPosition, maxContainerPosition)

        # move the dom object
        console.log(currentContainerPosition.x)
        console.log(currentContainerPosition.y)

        @stickerContainer.css
          left: currentContainerPosition.x
          top:  currentContainerPosition.y

        # Update the operation options
        @operationOptions.start = new Vector2()
          .copy(currentContainerPosition)
          .divideByRect(canvasRect)
        @operation.setOptions @operationOptions
        @updateCanvasControls()

      $(document).mouseup =>
        $(document).off "mousemove"
        $(document).off "mouseup"

module.exports = UIControlsStickers