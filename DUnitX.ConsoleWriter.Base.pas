{***************************************************************************}
{                                                                           }
{           DUnitX                                                          }
{                                                                           }
{           Copyright (C) 2013 Vincent Parrett                              }
{                                                                           }
{           vincent@finalbuilder.com                                        }
{           http://www.finalbuilder.com                                     }
{                                                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

unit DUnitX.ConsoleWriter.Base;

interface

uses
  classes;

{$I DUnitX.inc}


type
  TConsoleColour = (ccDefault, ccBrightRed, ccDarkRed,
                    ccBrightBlue, ccDarkBlue,
                    ccBrightGreen, ccDarkGreen,
                    ccBrightYellow, ccDarkYellow,
                    ccBrightAqua, ccDarkAqua,
                    ccBrightPurple, ccDarkPurple,
                    ccGrey, ccBlack,
                    ccBrightWhite,
                    ccWhite); // the normal colour of text on the console
  {$M+}
  IDUnitXConsoleWriter = interface
    ['{EFE59EB8-0C0B-4790-A964-D8126A2728A9}']
    function GetIndent : Integer;
    procedure SetIndent(const count: Integer);
    procedure SetColour(const foreground: TConsoleColour; const background: TConsoleColour = ccDefault);
    procedure WriteLn(const s: String);overload;
    procedure WriteLn;overload;
    procedure Write(const s : string);
    procedure Indent(const value : integer = 1);
    procedure Outdent(const value : integer = 1);
    property CurrentIndentLevel : Integer read GetIndent write SetIndent;

  end;

  TDUnitXConsoleWriterBase = class(TInterfacedObject,IDUnitXConsoleWriter)
  private
    FIndent : integer;
    FConsoleWidth : integer;
    FRedirectedStdOut : boolean;
  protected
    function GetIndent : Integer;
    procedure SetIndent(const count: Integer);virtual;
    procedure InternalWriteLn(const s : string); virtual;abstract;
    procedure InternalWrite(const s : string);virtual;abstract;
    procedure Indent(const value : integer = 1);
    procedure Outdent(const value : integer = 1);
    property ConsoleWidth : integer read FConsoleWidth write FConsoleWidth;
    property RedirectedStdOut : boolean read FRedirectedStdOut write FRedirectedStdOut;
  public
    constructor Create;virtual;
    procedure SetColour(const foreground: TConsoleColour; const background: TConsoleColour = ccDefault); virtual;abstract;
    procedure WriteLn(const s: String);overload;virtual;
    procedure WriteLn;overload;virtual;
    procedure Write(const s : string);virtual;
    property CurrentIndentLevel : Integer read GetIndent write SetIndent;
  end;


implementation

{ TDUnitXConsoleWriterBase }

constructor TDUnitXConsoleWriterBase.Create;
begin
  FConsoleWidth := 80;
  FIndent := 0;
end;


function TDUnitXConsoleWriterBase.GetIndent: Integer;
begin
  result := FIndent;
end;

procedure TDUnitXConsoleWriterBase.Indent(const value: integer);
begin
  SetIndent(FIndent + value);
end;

procedure TDUnitXConsoleWriterBase.Outdent(const value: integer);
begin
  SetIndent(FIndent - value);
end;

procedure TDUnitXConsoleWriterBase.SetIndent(const count: Integer);
begin
  if Count < 0 then
    FIndent := 0
  else
  begin
    FIndent := count;
    if not FRedirectedStdOut then
    begin
      if FIndent > FConsoleWidth -2  then
        FIndent := FConsoleWidth - 2;
    end;
  end;
end;


procedure TDUnitXConsoleWriterBase.Write(const s: string);
var
  offset, width, len : Integer;
begin
  width := FConsoleWidth - FIndent - 1;
  len := Length(s);
  if (width > 0) and (len > width) then // Need to break into multiple lines
  begin
    offset := 1;
    while offset < len do
    begin
      InternalWrite(Copy(s, offset, width));
      Inc(offset, width);
    end;
  end
  else // Can write out on a single line
    InternalWrite(s);
end;

procedure TDUnitXConsoleWriterBase.WriteLn;
begin
  WriteLn('');
end;

procedure TDUnitXConsoleWriterBase.WriteLn(const s: String);
var
  offset, width, len : Integer;
begin
  width := FConsoleWidth - FIndent - 1;
  len := Length(s);
  if (width > 0) and (len > width) then // Need to break into multiple lines
  begin
    offset := 1;
    while offset < len do
    begin
      InternalWriteLn(Copy(s, offset, width));
      Inc(offset, width);
    end;
  end
  else // Can write out on a single line
    InternalWriteLn(s);
end;

end.
