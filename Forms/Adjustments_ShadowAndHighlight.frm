VERSION 5.00
Begin VB.Form FormShadowHighlight 
   BackColor       =   &H80000005&
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   " Shadow / Midtone / Highlight"
   ClientHeight    =   6570
   ClientLeft      =   45
   ClientTop       =   285
   ClientWidth     =   12120
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
   ScaleHeight     =   438
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   808
   ShowInTaskbar   =   0   'False
   Begin PhotoDemon.pdCommandBar cmdBar 
      Align           =   2  'Align Bottom
      Height          =   750
      Left            =   0
      TabIndex        =   0
      Top             =   5820
      Width           =   12120
      _ExtentX        =   21378
      _ExtentY        =   1323
      BackColor       =   14802140
   End
   Begin PhotoDemon.pdFxPreviewCtl pdFxPreview 
      Height          =   5625
      Left            =   120
      TabIndex        =   1
      Top             =   120
      Width           =   5625
      _ExtentX        =   9922
      _ExtentY        =   9922
   End
   Begin PhotoDemon.pdButtonStrip btsOptions 
      Height          =   960
      Left            =   6000
      TabIndex        =   2
      Top             =   4800
      Width           =   5910
      _ExtentX        =   10425
      _ExtentY        =   1693
      Caption         =   "options"
   End
   Begin PhotoDemon.pdContainer picContainer 
      Height          =   4575
      Index           =   0
      Left            =   5880
      TabIndex        =   4
      Top             =   120
      Width           =   6135
      Begin PhotoDemon.pdSlider sltShadowAmount 
         Height          =   705
         Left            =   120
         TabIndex        =   6
         Top             =   720
         Width           =   5895
         _ExtentX        =   10398
         _ExtentY        =   1270
         Caption         =   "shadows"
         Min             =   -100
         Max             =   100
      End
      Begin PhotoDemon.pdSlider sltHighlightAmount 
         Height          =   705
         Left            =   120
         TabIndex        =   7
         Top             =   2820
         Width           =   5895
         _ExtentX        =   10398
         _ExtentY        =   1270
         Caption         =   "highlights"
         Min             =   -100
         Max             =   100
      End
      Begin PhotoDemon.pdSlider sltMidtoneContrast 
         Height          =   705
         Left            =   120
         TabIndex        =   8
         Top             =   1770
         Width           =   5895
         _ExtentX        =   10398
         _ExtentY        =   1270
         Caption         =   "midtone contrast"
         Min             =   -100
         Max             =   100
      End
   End
   Begin PhotoDemon.pdContainer picContainer 
      Height          =   4575
      Index           =   1
      Left            =   5880
      TabIndex        =   5
      Top             =   120
      Width           =   6135
      Begin PhotoDemon.pdSlider sltShadowWidth 
         Height          =   705
         Left            =   240
         TabIndex        =   11
         Top             =   360
         Width           =   5700
         _ExtentX        =   10054
         _ExtentY        =   1270
         Caption         =   "tonal width"
         Max             =   100
         Value           =   75
         NotchPosition   =   2
         NotchValueCustom=   75
      End
      Begin PhotoDemon.pdSlider sltShadowRadius 
         Height          =   705
         Left            =   240
         TabIndex        =   3
         Top             =   1200
         Width           =   5700
         _ExtentX        =   10054
         _ExtentY        =   1270
         Caption         =   "radius"
         Max             =   200
         Value           =   25
         NotchPosition   =   2
         NotchValueCustom=   25
      End
      Begin PhotoDemon.pdSlider sltHighlightWidth 
         Height          =   705
         Left            =   240
         TabIndex        =   9
         Top             =   2760
         Width           =   5700
         _ExtentX        =   10054
         _ExtentY        =   1270
         Caption         =   "tonal width"
         Max             =   100
         Value           =   75
         NotchPosition   =   2
         NotchValueCustom=   75
      End
      Begin PhotoDemon.pdSlider sltHighlightRadius 
         Height          =   705
         Left            =   240
         TabIndex        =   10
         Top             =   3600
         Width           =   5700
         _ExtentX        =   10054
         _ExtentY        =   1270
         Caption         =   "radius"
         Max             =   200
         Value           =   25
         NotchPosition   =   2
         NotchValueCustom=   25
      End
      Begin PhotoDemon.pdLabel lblTitle 
         Height          =   285
         Index           =   1
         Left            =   0
         Top             =   2340
         Width           =   5835
         _ExtentX        =   0
         _ExtentY        =   0
         Caption         =   "highlights"
         FontSize        =   12
         ForeColor       =   4210752
      End
      Begin PhotoDemon.pdLabel lblTitle 
         Height          =   285
         Index           =   0
         Left            =   0
         Top             =   0
         Width           =   5715
         _ExtentX        =   0
         _ExtentY        =   0
         Caption         =   "shadows"
         FontSize        =   12
         ForeColor       =   4210752
      End
   End
End
Attribute VB_Name = "FormShadowHighlight"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'***************************************************************************
'Shadow / Midtone / Highlight Adjustment Tool
'Copyright 2013-2016 by Tanner Helland
'Created: 17/February/13
'Last updated: 31/March/15
'Last update: total overhaul of the shadow/highlight adjustment strategy
'
'This tool provides detailed control over the shadow and/or highlight regions of an image.  A combination of
' heuristics and user-editable parameters allow for brightening and/or darkening any luminance range in the
' source image.
'
'Note that the bulk of the image processing does not occur here, but in the separate AdjustDIBShadowHighlight
' function (currently inside the Filters_Layers module).
'
'All source code in this file is licensed under a modified BSD license.  This means you may use the code in your own
' projects IF you provide attribution.  For more information, please visit http://photodemon.org/about/license/
'
'***************************************************************************

Option Explicit

Private Sub btsOptions_Click(ByVal buttonIndex As Long)
    picContainer(buttonIndex).Visible = True
    picContainer(1 - buttonIndex).Visible = False
End Sub

'OK button
Private Sub cmdBar_OKClick()
    Process "Shadow and highlight", , buildParams(sltShadowAmount, sltMidtoneContrast, sltHighlightAmount, sltShadowWidth, sltShadowRadius, sltHighlightWidth, sltHighlightRadius), UNDO_LAYER
End Sub

Private Sub cmdBar_RequestPreviewUpdate()
    UpdatePreview
End Sub

Private Sub cmdBar_ResetClick()
    sltShadowWidth.Value = 75
    sltHighlightWidth.Value = 75
    sltShadowRadius.Value = 25
    sltHighlightRadius.Value = 25
End Sub

Private Sub Form_Activate()
    
    'Apply translations and visual themes
    ApplyThemeAndTranslations Me
    
    'Render an initial preview
    UpdatePreview
    
End Sub

'Correct white balance by stretching the histogram and ignoring pixels above or below the 0.05% threshold
Public Sub ApplyShadowHighlight(ByVal shadowAmount As Double, ByVal midtoneContrast As Double, ByVal highlightAmount As Double, Optional ByVal shadowWidth As Long = 50, Optional ByVal shadowRadius As Double = 0, Optional ByVal highlightWidth As Long = 50, Optional ByVal highlightRadius As Double = 0, Optional ByVal toPreview As Boolean = False, Optional ByRef dstPic As pdFxPreviewCtl)

    If Not toPreview Then Message "Adjusting shadows, midtones, and highlights..."
    
    'Create a local array and point it at the pixel data of the current image
    Dim dstSA As SAFEARRAY2D
    prepImageData dstSA, toPreview, dstPic
    
    AdjustDIBShadowHighlight shadowAmount, midtoneContrast, highlightAmount, shadowWidth, shadowRadius * curDIBValues.previewModifier, highlightWidth, highlightRadius * curDIBValues.previewModifier, workingDIB, toPreview
    
    'Pass control to finalizeImageData, which will handle the rest of the rendering using the data inside workingDIB
    finalizeImageData toPreview, dstPic
    
End Sub

Private Sub Form_Load()
    
    'Set up the basic/advanced panels
    btsOptions.AddItem "basic", 0
    btsOptions.AddItem "advanced", 1
    btsOptions.ListIndex = 0
    btsOptions_Click 0
    
End Sub

Private Sub Form_Unload(Cancel As Integer)
    ReleaseFormTheming Me
End Sub

Private Sub UpdatePreview()
    If cmdBar.previewsAllowed Then ApplyShadowHighlight sltShadowAmount, sltMidtoneContrast, sltHighlightAmount, sltShadowWidth, sltShadowRadius, sltHighlightWidth, sltHighlightRadius, True, pdFxPreview
End Sub

'If the user changes the position and/or zoom of the preview viewport, the entire preview must be redrawn.
Private Sub pdFxPreview_ViewportChanged()
    UpdatePreview
End Sub

Private Sub sltHighlightAmount_Change()
    UpdatePreview
End Sub

Private Sub sltHighlightRadius_Change()
    UpdatePreview
End Sub

Private Sub sltHighlightWidth_Change()
    UpdatePreview
End Sub

Private Sub sltMidtoneContrast_Change()
    UpdatePreview
End Sub

Private Sub sltShadowAmount_Change()
    UpdatePreview
End Sub

Private Sub sltShadowRadius_Change()
    UpdatePreview
End Sub

Private Sub sltShadowWidth_Change()
    UpdatePreview
End Sub





