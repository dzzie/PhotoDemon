VERSION 5.00
Begin VB.Form FormVignette 
   AutoRedraw      =   -1  'True
   BackColor       =   &H80000005&
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   " Apply Vignetting"
   ClientHeight    =   6540
   ClientLeft      =   -15
   ClientTop       =   225
   ClientWidth     =   12090
   BeginProperty Font 
      Name            =   "Tahoma"
      Size            =   8.25
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   436
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   806
   ShowInTaskbar   =   0   'False
   Begin PhotoDemon.pdSlider sltXCenter 
      Height          =   405
      Left            =   6000
      TabIndex        =   2
      Top             =   480
      Width           =   2895
      _ExtentX        =   5106
      _ExtentY        =   873
      Max             =   1
      SigDigits       =   2
      Value           =   0.5
      NotchPosition   =   2
      NotchValueCustom=   0.5
   End
   Begin PhotoDemon.pdCommandBar cmdBar 
      Align           =   2  'Align Bottom
      Height          =   750
      Left            =   0
      TabIndex        =   0
      Top             =   5790
      Width           =   12090
      _ExtentX        =   21325
      _ExtentY        =   1323
   End
   Begin PhotoDemon.pdRadioButton optShape 
      Height          =   360
      Index           =   0
      Left            =   6120
      TabIndex        =   3
      Top             =   5340
      Width           =   2700
      _ExtentX        =   4763
      _ExtentY        =   582
      Caption         =   "fit to image"
      Value           =   -1  'True
   End
   Begin PhotoDemon.pdFxPreviewCtl pdFxPreview 
      Height          =   5625
      Left            =   120
      TabIndex        =   1
      Top             =   120
      Width           =   5625
      _ExtentX        =   9922
      _ExtentY        =   9922
      DisableZoomPan  =   -1  'True
      PointSelection  =   -1  'True
   End
   Begin PhotoDemon.pdRadioButton optShape 
      Height          =   360
      Index           =   1
      Left            =   8880
      TabIndex        =   4
      Top             =   5340
      Width           =   2700
      _ExtentX        =   4763
      _ExtentY        =   582
      Caption         =   "circular"
   End
   Begin PhotoDemon.pdSlider sltRadius 
      Height          =   705
      Left            =   6000
      TabIndex        =   5
      Top             =   1440
      Width           =   5895
      _ExtentX        =   10398
      _ExtentY        =   1270
      Caption         =   "radius"
      Min             =   1
      Max             =   100
      Value           =   50
      NotchPosition   =   2
      NotchValueCustom=   50
   End
   Begin PhotoDemon.pdSlider sltFeathering 
      Height          =   705
      Left            =   6000
      TabIndex        =   6
      Top             =   2280
      Width           =   5895
      _ExtentX        =   10398
      _ExtentY        =   1270
      Caption         =   "softness"
      Min             =   1
      Max             =   100
      Value           =   1
      DefaultValue    =   1
   End
   Begin PhotoDemon.pdSlider sltTransparency 
      Height          =   705
      Left            =   6000
      TabIndex        =   7
      Top             =   3120
      Width           =   5895
      _ExtentX        =   10398
      _ExtentY        =   1270
      Caption         =   "strength"
      Min             =   1
      Max             =   100
      Value           =   100
      DefaultValue    =   100
   End
   Begin PhotoDemon.pdColorSelector colorPicker 
      Height          =   930
      Left            =   6000
      TabIndex        =   8
      Top             =   3900
      Width           =   5775
      _ExtentX        =   10186
      _ExtentY        =   1640
      Caption         =   "color"
      curColor        =   0
   End
   Begin PhotoDemon.pdSlider sltYCenter 
      Height          =   405
      Left            =   9000
      TabIndex        =   9
      Top             =   480
      Width           =   2895
      _ExtentX        =   5106
      _ExtentY        =   873
      Max             =   1
      SigDigits       =   2
      Value           =   0.5
      NotchPosition   =   2
      NotchValueCustom=   0.5
   End
   Begin PhotoDemon.pdLabel lblExplanation 
      Height          =   435
      Index           =   0
      Left            =   6120
      Top             =   1050
      Width           =   5655
      _ExtentX        =   0
      _ExtentY        =   0
      Caption         =   "Note: you can also set a center position by clicking the preview window."
      FontSize        =   9
      ForeColor       =   4210752
      Layout          =   1
   End
   Begin PhotoDemon.pdLabel lblTitle 
      Height          =   285
      Index           =   0
      Left            =   6000
      Top             =   120
      Width           =   5925
      _ExtentX        =   0
      _ExtentY        =   0
      Caption         =   "center position (x, y)"
      FontSize        =   12
      ForeColor       =   4210752
   End
   Begin PhotoDemon.pdLabel lblTitle 
      Height          =   285
      Index           =   1
      Left            =   6000
      Top             =   4980
      Width           =   5895
      _ExtentX        =   0
      _ExtentY        =   0
      Caption         =   "shape"
      FontSize        =   12
      ForeColor       =   4210752
   End
End
Attribute VB_Name = "FormVignette"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'***************************************************************************
'Image Vignette tool
'Copyright 2013-2016 by Tanner Helland
'Created: 31/January/13
'Last updated: 09/January/14
'Last update: added center-point selection capabilities
'
'This tool allows the user to apply vignetting to an image.  Many options are available, and all should be
' self-explanatory!
'
'All source code in this file is licensed under a modified BSD license.  This means you may use the code in your own
' projects IF you provide attribution.  For more information, please visit http://photodemon.org/about/license/
'
'***************************************************************************

Option Explicit

'Apply vignetting to an image
Public Sub ApplyVignette(ByVal maxRadius As Double, ByVal vFeathering As Double, ByVal vTransparency As Double, ByVal vMode As Boolean, ByVal newColor As Long, Optional ByVal centerPosX As Double = 0.5, Optional ByVal centerPosY As Double = 0.5, Optional ByVal toPreview As Boolean = False, Optional ByRef dstPic As pdFxPreviewCtl)
    
    If Not toPreview Then Message "Applying vignetting..."
        
    'Extract the RGB values of the vignetting color
    Dim newR As Byte, newG As Byte, newB As Byte
    newR = Colors.ExtractRed(newColor)
    newG = Colors.ExtractGreen(newColor)
    newB = Colors.ExtractBlue(newColor)
    
    'Create a local array and point it at the pixel data of the current image
    Dim dstImageData() As Byte
    Dim dstSA As SAFEARRAY2D
    PrepImageData dstSA, toPreview, dstPic
    CopyMemory ByVal VarPtrArray(dstImageData()), VarPtr(dstSA), 4
    
    'Local loop variables can be more efficiently cached by VB's compiler, so we transfer all relevant loop data here
    Dim x As Long, y As Long, initX As Long, initY As Long, finalX As Long, finalY As Long
    initX = curDIBValues.Left
    initY = curDIBValues.Top
    finalX = curDIBValues.Right
    finalY = curDIBValues.Bottom
            
    'These values will help us access locations in the array more quickly.
    ' (qvDepth is required because the image array may be 24 or 32 bits per pixel, and we want to handle both cases.)
    Dim QuickVal As Long, qvDepth As Long
    qvDepth = curDIBValues.BytesPerPixel
    
    'To keep processing quick, only update the progress bar when absolutely necessary.  This function calculates that value
    ' based on the size of the area to be processed.
    Dim progBarCheck As Long
    progBarCheck = FindBestProgBarValue()
        
    'Calculate the center of the image
    Dim midX As Double, midY As Double
    midX = CDbl(finalX - initX) * centerPosX
    midX = midX + initX
    midY = CDbl(finalY - initY) * centerPosY
    midY = midY + initY
            
    'X and Y values, remapped around a center point of (0, 0)
    Dim nX As Double, nY As Double
    Dim nX2 As Double, nY2 As Double
            
    'Radius is based off the smaller of the two dimensions - width or height
    Dim tWidth As Long, tHeight As Long
    tWidth = curDIBValues.Width
    tHeight = curDIBValues.Height
    Dim sRadiusW As Double, sRadiusH As Double
    Dim sRadiusW2 As Double, sRadiusH2 As Double
    
    sRadiusW = tWidth * (maxRadius / 100)
    sRadiusW2 = sRadiusW * sRadiusW
    sRadiusH = tHeight * (maxRadius / 100)
    sRadiusH2 = sRadiusH * sRadiusH
    
    'Adjust the vignetting to be a proportion of the image's maximum radius.  This ensures accurate correlations
    ' between the preview and the final result.
    Dim vFeathering2 As Double
    
    If vMode Then
        vFeathering2 = (vFeathering / 100) * (sRadiusW * sRadiusH)
    Else
        If sRadiusW < sRadiusH Then
            vFeathering2 = (vFeathering / 100) * (sRadiusW * sRadiusW)
        Else
            vFeathering2 = (vFeathering / 100) * (sRadiusH * sRadiusH)
        End If
    End If
    
    'Modify the transparency to be on a scale of [0, 1]
    vTransparency = 1 - (vTransparency / 100)
    
    Dim sRadiusCircular As Double, sRadiusMax As Double, sRadiusMin As Double
    If sRadiusW < sRadiusH Then
        sRadiusCircular = sRadiusW2
    Else
        sRadiusCircular = sRadiusH2
    End If
    sRadiusMin = sRadiusCircular - vFeathering2
    
    Dim blendVal As Double
        
    'Loop through each pixel in the image, converting values as we go
    For x = initX To finalX
        QuickVal = x * qvDepth
    For y = initY To finalY
    
        'Remap the coordinates around a center point of (0, 0)
        nX = x - midX
        nY = y - midY
        nX2 = nX * nX
        nY2 = nY * nY
                
        'Fit to image (elliptical)
        If vMode Then
                
            'If the values are going to be out-of-bounds, force them to black
            sRadiusMax = sRadiusH2 - ((sRadiusH2 * nX2) / sRadiusW2)
            
            If nY2 > sRadiusMax Then
                
                dstImageData(QuickVal + 2, y) = BlendColors(newR, dstImageData(QuickVal + 2, y), vTransparency)
                dstImageData(QuickVal + 1, y) = BlendColors(newG, dstImageData(QuickVal + 1, y), vTransparency)
                dstImageData(QuickVal, y) = BlendColors(newB, dstImageData(QuickVal, y), vTransparency)
                
            'Otherwise, check for feathering
            Else
                sRadiusMin = sRadiusMax - vFeathering2
                
                If nY2 >= sRadiusMin Then
                    blendVal = (nY2 - sRadiusMin) / vFeathering2
                    blendVal = blendVal * (1 - vTransparency)
                    
                    dstImageData(QuickVal + 2, y) = BlendColors(dstImageData(QuickVal + 2, y), newR, blendVal)
                    dstImageData(QuickVal + 1, y) = BlendColors(dstImageData(QuickVal + 1, y), newG, blendVal)
                    dstImageData(QuickVal, y) = BlendColors(dstImageData(QuickVal, y), newB, blendVal)
                End If
                    
            End If
                
        'Circular
        Else
        
            'If the values are going to be out-of-bounds, force them to black
            If (nX2 + nY2) > sRadiusCircular Then
                dstImageData(QuickVal + 2, y) = BlendColors(newR, dstImageData(QuickVal + 2, y), vTransparency)
                dstImageData(QuickVal + 1, y) = BlendColors(newG, dstImageData(QuickVal + 1, y), vTransparency)
                dstImageData(QuickVal, y) = BlendColors(newB, dstImageData(QuickVal, y), vTransparency)
                
            'Otherwise, check for feathering
            Else
                
                If (nX2 + nY2) >= sRadiusMin Then
                    blendVal = (nX2 + nY2 - sRadiusMin) / vFeathering2
                    blendVal = blendVal * (1 - vTransparency)
                    
                    dstImageData(QuickVal + 2, y) = BlendColors(dstImageData(QuickVal + 2, y), newR, blendVal)
                    dstImageData(QuickVal + 1, y) = BlendColors(dstImageData(QuickVal + 1, y), newG, blendVal)
                    dstImageData(QuickVal, y) = BlendColors(dstImageData(QuickVal, y), newB, blendVal)
                End If
                
            End If
                
        End If
                        
    Next y
        If Not toPreview Then
            If (x And progBarCheck) = 0 Then
                If UserPressedESC() Then Exit For
                SetProgBarVal x
            End If
        End If
    Next x
    
    'With our work complete, point both ImageData() arrays away from their DIBs and deallocate them
    CopyMemory ByVal VarPtrArray(dstImageData), 0&, 4
    Erase dstImageData
    
    'Pass control to finalizeImageData, which will handle the rest of the rendering
    FinalizeImageData toPreview, dstPic
        
End Sub

Private Sub cmdBar_OKClick()
    Process "Vignetting", , BuildParams(sltRadius.Value, sltFeathering.Value, sltTransparency.Value, optShape(0).Value, colorPicker.Color, sltXCenter.Value, sltYCenter.Value), UNDO_LAYER
End Sub

Private Sub cmdBar_RequestPreviewUpdate()
    UpdatePreview
End Sub

Private Sub cmdBar_ResetClick()
    colorPicker.Color = RGB(0, 0, 0)
End Sub

Private Sub colorPicker_ColorChanged()
    UpdatePreview
End Sub

Private Sub Form_Activate()
        
    'Apply translations and visual themes
    ApplyThemeAndTranslations Me
    
    'Draw a preview of the effect
    UpdatePreview
    
End Sub

Private Sub Form_Unload(Cancel As Integer)
    ReleaseFormTheming Me
End Sub

Private Sub pdFxPreview_ColorSelected()
    colorPicker.Color = pdFxPreview.SelectedColor
    UpdatePreview
End Sub

'The user can right-click the preview area to select a new center point
Private Sub pdFxPreview_PointSelected(xRatio As Double, yRatio As Double)
    
    cmdBar.MarkPreviewStatus False
    sltXCenter.Value = xRatio
    sltYCenter.Value = yRatio
    cmdBar.MarkPreviewStatus True
    UpdatePreview
    
End Sub

Private Sub optShape_Click(Index As Integer)
    UpdatePreview
End Sub

Private Sub sltFeathering_Change()
    UpdatePreview
End Sub

Private Sub sltRadius_Change()
    UpdatePreview
End Sub

Private Sub sltTransparency_Change()
    UpdatePreview
End Sub

'Redraw the on-screen preview of the transformed image
Private Sub UpdatePreview()
    If cmdBar.PreviewsAllowed Then ApplyVignette sltRadius.Value, sltFeathering.Value, sltTransparency.Value, optShape(0).Value, colorPicker.Color, sltXCenter.Value, sltYCenter.Value, True, pdFxPreview
End Sub

'If the user changes the position and/or zoom of the preview viewport, the entire preview must be redrawn.
Private Sub pdFxPreview_ViewportChanged()
    UpdatePreview
End Sub

Private Sub sltXCenter_Change()
    UpdatePreview
End Sub

Private Sub sltYCenter_Change()
    UpdatePreview
End Sub






