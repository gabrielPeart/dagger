; RUN: opt < %s -instcombine -S | FileCheck %s

define i32 @test1(i32 %A) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    ret i32 %A
;
  %B = xor i32 %A, -1
  %C = xor i32 %B, -1
  ret i32 %C
}

define i1 @invert_icmp(i32 %A, i32 %B) {
; CHECK-LABEL: @invert_icmp(
; CHECK-NEXT:    [[NOT:%.*]] = icmp sgt i32 %A, %B
; CHECK-NEXT:    ret i1 [[NOT]]
;
  %cmp = icmp sle i32 %A, %B
  %not = xor i1 %cmp, true
  ret i1 %not
}

; PR1570

define i1 @invert_fcmp(float %X, float %Y) {
; CHECK-LABEL: @invert_fcmp(
; CHECK-NEXT:    [[NOT:%.*]] = fcmp uge float %X, %Y
; CHECK-NEXT:    ret i1 [[NOT]]
;
  %cmp = fcmp olt float %X, %Y
  %not = xor i1 %cmp, true
  ret i1 %not
}

; Test that De Morgan's law can be instcombined.
define i32 @test3(i32 %A, i32 %B) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    [[C_DEMORGAN:%.*]] = or i32 %A, %B
; CHECK-NEXT:    ret i32 [[C_DEMORGAN]]
;
  %a = xor i32 %A, -1
  %b = xor i32 %B, -1
  %c = and i32 %a, %b
  %d = xor i32 %c, -1
  ret i32 %d
}

; Test that De Morgan's law can work with constants.
define i32 @test4(i32 %A, i32 %B) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:    [[D1:%.*]] = or i32 %A, -6
; CHECK-NEXT:    ret i32 [[D1]]
;
  %a = xor i32 %A, -1
  %c = and i32 %a, 5
  %d = xor i32 %c, -1
  ret i32 %d
}

; Test the mirror of De Morgan's law.
define i32 @test5(i32 %A, i32 %B) {
; CHECK-LABEL: @test5(
; CHECK-NEXT:    [[C_DEMORGAN:%.*]] = and i32 %A, %B
; CHECK-NEXT:    ret i32 [[C_DEMORGAN]]
;
  %a = xor i32 %A, -1
  %b = xor i32 %B, -1
  %c = or i32 %a, %b
  %d = xor i32 %c, -1
  ret i32 %d
}

; PR2298
define zeroext i8 @test6(i32 %a, i32 %b) {
; CHECK-LABEL: @test6(
; CHECK-NEXT:    [[TMP3:%.*]] = icmp slt i32 %b, %a
; CHECK-NEXT:    [[RETVAL67:%.*]] = zext i1 [[TMP3]] to i8
; CHECK-NEXT:    ret i8 [[RETVAL67]]
;
  %tmp1not = xor i32 %a, -1
  %tmp2not = xor i32 %b, -1
  %tmp3 = icmp slt i32 %tmp1not, %tmp2not
  %retval67 = zext i1 %tmp3 to i8
  ret i8 %retval67
}

define <2 x i1> @test7(<2 x i32> %A, <2 x i32> %B) {
; CHECK-LABEL: @test7(
; CHECK-NEXT:    [[RET:%.*]] = icmp sgt <2 x i32> %A, %B
; CHECK-NEXT:    ret <2 x i1> [[RET]]
;
  %cond = icmp sle <2 x i32> %A, %B
  %Ret = xor <2 x i1> %cond, <i1 true, i1 true>
  ret <2 x i1> %Ret
}

