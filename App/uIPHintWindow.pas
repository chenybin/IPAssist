unit uIPHintWindow;

interface

uses
    Controls, Classes, Windows, Graphics, Forms;

type
    TIPHintWindow = class(THintWindow)
    private
        {   Private   declarations   }
        FActivating:Boolean;
        slHint:TStringList;
    protected
        {   Protected   declarations   }
    public
        {   Public   declarations   }
        constructor Create(AOwner:TComponent); override;
        destructor Destroy; override;

        procedure CalcSize(ACanvas:TCanvas; const AHint:string; var _R:TRect);
        procedure Activatehint(Rect:TRect; const AHint:string); override;
        procedure Paint; override;
        procedure NCPaint(DC:HDC); override;
        procedure CreateParams(var Params:TCreateParams); override;
    published
        {   Published   declarations   }
        property Canvas; //
    end;

implementation

uses Types;

{ TIPHintWindow }

procedure TIPHintWindow.Paint;
var
    Rect:TRect;
    nWidth, nHeight:Integer;
begin
    Rect := ClientRect;

    // Hint边框颜色
    with Canvas do begin
        Brush.Color := TColor($DBB8BA);
        FillRect(rect);
        // 绘制整个Hint的边框
        Pen.Color := TColor($69230E);
        // 矩形
        //Canvas.Rectangle(rect);

        // 圆角矩形
        nWidth := rect.right - rect.Left;
        nHeight := rect.Bottom - rect.Top;
        Canvas.RoundRect(0, // 左上角的x坐标
            0, // 左上角的y坐标
            nWidth - 1, // 右下角的x坐标
            nHeight - 1, // 右下角的y坐标
            5, // 圆角的高度
            5); // 圆角的宽度) Rectangle(rect);

        // Hint背景的颜色
        Color := clWhite;
        // Hint文字透明
        Canvas.Brush.Style := bsClear;
        // 绘出Hint文字
        Canvas.Font.Color := clBlack;

        // 重新设定文字的范围
        Inc(rect.Left, 10);
        DEc(rect.Right, 10);
        Inc(rect.Top, 5);
        Dec(rect.Bottom, 5);

        DrawText(Canvas.Handle, PChar(Caption), Length(Caption), Rect, DT_NOPREFIX or
            DT_WORDBREAK or DT_VCENTER);

        // Textout  不能换行
        //Canvas.TextOut(4, Round(rect.Bottom / 2)
            //- Round(Canvas.TextHeight(Caption) / 2), Caption);
    end;
end;

procedure TIPHintWindow.NCPaint(DC:HDC);
begin
    Invalidate();
end;

procedure TIPHintWindow.CreateParams(var Params:TCreateParams);
begin
    inherited;
    Params.Style := Params.Style and not ws_Border;
end;

procedure TIPHintWindow.Activatehint(Rect:TRect; const AHint:string);
var
    R:TREct;
    hrgn1:HRGN;
    nWidth, nHeight:Integer;
begin
    FActivating := true;
    try
        Caption := AHint;
        CalcSize(Canvas, AHint, Rect);
        r := Rect;
        Dec(r.Left, 10);
        Inc(r.Right, 10);
        Dec(r.Top, 5);
        Inc(r.Bottom, 5);
        nWidth := r.right - r.Left;
        nHeight := r.Bottom - r.Top;
        // 更新区域
        UpdateBoundsRect(r);
        // Hint窗口处于屏幕边缘时的调整
        if (r.Top + Height > Screen.DesktopHeight) then
            r.Top := Screen.DesktopHeight - Height;
        if (r.Left + Width > Screen.DesktopWidth) then
            r.Left := Screen.DesktopWidth - Width;
        if (r.Left < Screen.DesktopLeft) then
            r.Left := Screen.DesktopLeft;
        if (r.Bottom < Screen.DesktopTop) then
            r.Bottom := Screen.DesktopTop;
        // 创建一个矩形
        // 63 63 72 75 6E 2E 63 6F 6D
        //hrgn1 := CreateRectRgn(0, 0, nWidth, nHeight);
        // 圆角矩形
        hrgn1 := CreateRoundRectRgn(0, // 左上角的x坐标
            0, // 左上角的y坐标
            nWidth, // 右下角的x坐标
            nHeight, // 右下角的y坐标
            5, // 圆角的高度
            5); // 圆角的宽度
        // 设置指定句柄的窗口形状
        SetWindowRgn(Handle, hrgn1, true);
        // 改变窗口的位置,Z Order,及其他一些属性
        SetWindowPos(Handle, HWND_TOPMOST, r.Left, r.Top, nWidth,
            nHeight, SWP_SHOWWINDOW + SWP_NOACTIVATE);
        // 重画窗口
        Invalidate();
        DeleteObject(hrgn1); // 释放资源
    finally
        FActivating := false;
    end;
end;

constructor TIPHintWindow.Create(AOwner:TComponent);
begin
    inherited;
    with Canvas.Font do begin
        Name := '宋体';
        Color := clBlack;
        Size := 9;
    end;
    slHint := TStringList.Create;
end;

procedure TIPHintWindow.CalcSize(ACanvas:TCanvas; const AHint:string; var _R:TRect);
var
    nRow:Integer;
    nMaxLength, i:Integer;
    nWidth, nHight:Integer;
begin
    // 重新计算宽度，主要是为了多个回车的问题
    slHint.Text := AHint;
    nRow := slHint.Count;
    nMaxLength := 0;
    for i := 0 to nRow - 1 do
        if Length(slHint.Strings[i]) > nMaxLength then nMaxLength := Length(slHint.Strings[i]);

    nWidth := ACanvas.TextWidth('H');
    nHight := ACanvas.TextWidth('lj');
    with _R do begin
        Right := Left + nWidth * nMaxLength;
        Bottom := Top + nHight * nRow;
    end;
end;

destructor TIPHintWindow.Destroy;
begin
    slHint.Free;
    inherited;
end;

end.

