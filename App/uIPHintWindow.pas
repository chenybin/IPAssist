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

    // Hint�߿���ɫ
    with Canvas do begin
        Brush.Color := TColor($DBB8BA);
        FillRect(rect);
        // ��������Hint�ı߿�
        Pen.Color := TColor($69230E);
        // ����
        //Canvas.Rectangle(rect);

        // Բ�Ǿ���
        nWidth := rect.right - rect.Left;
        nHeight := rect.Bottom - rect.Top;
        Canvas.RoundRect(0, // ���Ͻǵ�x����
            0, // ���Ͻǵ�y����
            nWidth - 1, // ���½ǵ�x����
            nHeight - 1, // ���½ǵ�y����
            5, // Բ�ǵĸ߶�
            5); // Բ�ǵĿ��) Rectangle(rect);

        // Hint��������ɫ
        Color := clWhite;
        // Hint����͸��
        Canvas.Brush.Style := bsClear;
        // ���Hint����
        Canvas.Font.Color := clBlack;

        // �����趨���ֵķ�Χ
        Inc(rect.Left, 10);
        DEc(rect.Right, 10);
        Inc(rect.Top, 5);
        Dec(rect.Bottom, 5);

        DrawText(Canvas.Handle, PChar(Caption), Length(Caption), Rect, DT_NOPREFIX or
            DT_WORDBREAK or DT_VCENTER);

        // Textout  ���ܻ���
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
        // ��������
        UpdateBoundsRect(r);
        // Hint���ڴ�����Ļ��Եʱ�ĵ���
        if (r.Top + Height > Screen.DesktopHeight) then
            r.Top := Screen.DesktopHeight - Height;
        if (r.Left + Width > Screen.DesktopWidth) then
            r.Left := Screen.DesktopWidth - Width;
        if (r.Left < Screen.DesktopLeft) then
            r.Left := Screen.DesktopLeft;
        if (r.Bottom < Screen.DesktopTop) then
            r.Bottom := Screen.DesktopTop;
        // ����һ������
        // 63 63 72 75 6E 2E 63 6F 6D
        //hrgn1 := CreateRectRgn(0, 0, nWidth, nHeight);
        // Բ�Ǿ���
        hrgn1 := CreateRoundRectRgn(0, // ���Ͻǵ�x����
            0, // ���Ͻǵ�y����
            nWidth, // ���½ǵ�x����
            nHeight, // ���½ǵ�y����
            5, // Բ�ǵĸ߶�
            5); // Բ�ǵĿ��
        // ����ָ������Ĵ�����״
        SetWindowRgn(Handle, hrgn1, true);
        // �ı䴰�ڵ�λ��,Z Order,������һЩ����
        SetWindowPos(Handle, HWND_TOPMOST, r.Left, r.Top, nWidth,
            nHeight, SWP_SHOWWINDOW + SWP_NOACTIVATE);
        // �ػ�����
        Invalidate();
        DeleteObject(hrgn1); // �ͷ���Դ
    finally
        FActivating := false;
    end;
end;

constructor TIPHintWindow.Create(AOwner:TComponent);
begin
    inherited;
    with Canvas.Font do begin
        Name := '����';
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
    // ���¼����ȣ���Ҫ��Ϊ�˶���س�������
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

