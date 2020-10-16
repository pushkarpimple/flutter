// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TextEditingValue testOldValue = TextEditingValue.empty;
  TextEditingValue testNewValue = TextEditingValue.empty;

  test('withFunction wraps formatting function', () {
    testOldValue = const TextEditingValue();
    testNewValue = const TextEditingValue();

    late TextEditingValue calledOldValue;
    late TextEditingValue calledNewValue;

    final TextInputFormatter formatterUnderTest = TextInputFormatter.withFunction(
      (TextEditingValue oldValue, TextEditingValue newValue) {
        calledOldValue = oldValue;
        calledNewValue = newValue;
        return TextEditingValue.empty;
      }
    );

    formatterUnderTest.formatEditUpdate(testOldValue, testNewValue);

    expect(calledOldValue, equals(testOldValue));
    expect(calledNewValue, equals(testNewValue));
  });

  group('test provided formatters', () {
    setUp(() {
      // a1b(2c3
      // d4)e5f6
      // where the parentheses are the selection range.
      testNewValue = const TextEditingValue(
        text: 'a1b2c3\nd4e5f6',
        selection: TextSelection(
          baseOffset: 3,
          extentOffset: 9,
        ),
      );
    });

    test('test filtering formatter example', () {
      const TextEditingValue intoTheWoods = TextEditingValue(text: 'Into the Woods');
      expect(
        FilteringTextInputFormatter('o', allow: true, replacementString: '*').formatEditUpdate(testOldValue, intoTheWoods),
        const TextEditingValue(text: '*o*oo*'),
      );
      expect(
        FilteringTextInputFormatter('o', allow: false, replacementString: '*').formatEditUpdate(testOldValue, intoTheWoods),
        const TextEditingValue(text: 'Int* the W**ds'),
      );
      expect(
        FilteringTextInputFormatter(RegExp('o+'), allow: true, replacementString: '*').formatEditUpdate(testOldValue, intoTheWoods),
        const TextEditingValue(text: '*o*oo*'),
      );
      expect(
        FilteringTextInputFormatter(RegExp('o+'), allow: false, replacementString: '*').formatEditUpdate(testOldValue, intoTheWoods),
        const TextEditingValue(text: 'Int* the W*ds'),
      );

      const TextEditingValue selectedIntoTheWoods = TextEditingValue(text: 'Into the Woods', selection: TextSelection(baseOffset: 11, extentOffset: 14));
      expect(
        FilteringTextInputFormatter('o', allow: true, replacementString: '*').formatEditUpdate(testOldValue, selectedIntoTheWoods),
        const TextEditingValue(text: '*o*oo*', selection: TextSelection(baseOffset: 4, extentOffset: 6)),
      );
      expect(
        FilteringTextInputFormatter('o', allow: false, replacementString: '*').formatEditUpdate(testOldValue, selectedIntoTheWoods),
        const TextEditingValue(text: 'Int* the W**ds', selection: TextSelection(baseOffset: 11, extentOffset: 14)),
      );
      expect(
        FilteringTextInputFormatter(RegExp('o+'), allow: true, replacementString: '*').formatEditUpdate(testOldValue, selectedIntoTheWoods),
        const TextEditingValue(text: '*o*oo*', selection: TextSelection(baseOffset: 4, extentOffset: 6)),
      );
      expect(
        FilteringTextInputFormatter(RegExp('o+'), allow: false, replacementString: '*').formatEditUpdate(testOldValue, selectedIntoTheWoods),
        const TextEditingValue(text: 'Int* the W**ds', selection: TextSelection(baseOffset: 11, extentOffset: 14)),
      );
    });

    test('test filtering formatter, deny mode', () {
      final TextEditingValue actualValue =
          FilteringTextInputFormatter.deny(RegExp(r'[a-z]'))
              .formatEditUpdate(testOldValue, testNewValue);

      // Expecting
      // 1(23
      // 4)56
      expect(actualValue, const TextEditingValue(
        text: '123\n456',
        selection: TextSelection(
          baseOffset: 1,
          extentOffset: 5,
        ),
      ));
    });

    test('test filtering formatter, deny mode (deprecated names)', () {
      final TextEditingValue actualValue =
          FilteringTextInputFormatter.deny(RegExp(r'[a-z]'))
              .formatEditUpdate(testOldValue, testNewValue);

      // Expecting
      // 1(23
      // 4)56
      expect(actualValue, const TextEditingValue(
        text: '123\n456',
        selection: TextSelection(
          baseOffset: 1,
          extentOffset: 5,
        ),
      ));
    });

    test('test single line formatter', () {
      final TextEditingValue actualValue =
          FilteringTextInputFormatter.singleLineFormatter
              .formatEditUpdate(testOldValue, testNewValue);

      // Expecting
      // a1b(2c3d4)e5f6
      expect(actualValue, const TextEditingValue(
        text: 'a1b2c3d4e5f6',
        selection: TextSelection(
          baseOffset: 3,
          extentOffset: 8,
        ),
      ));
    });

    test('test single line formatter (deprecated names)', () {
      final TextEditingValue actualValue =
          FilteringTextInputFormatter.singleLineFormatter
              .formatEditUpdate(testOldValue, testNewValue);

      // Expecting
      // a1b(2c3d4)e5f6
      expect(actualValue, const TextEditingValue(
        text: 'a1b2c3d4e5f6',
        selection: TextSelection(
          baseOffset: 3,
          extentOffset: 8,
        ),
      ));
    });

    test('test filtering formatter, allow mode', () {
      final TextEditingValue actualValue =
          FilteringTextInputFormatter.allow(RegExp(r'[a-c]'))
              .formatEditUpdate(testOldValue, testNewValue);

      // Expecting
      // ab(c)
      expect(actualValue, const TextEditingValue(
        text: 'abc',
        selection: TextSelection(
          baseOffset: 2,
          extentOffset: 3,
        ),
      ));
    });

    test('test filtering formatter, allow mode (deprecated names)', () {
      final TextEditingValue actualValue =
          FilteringTextInputFormatter.allow(RegExp(r'[a-c]'))
              .formatEditUpdate(testOldValue, testNewValue);

      // Expecting
      // ab(c)
      expect(actualValue, const TextEditingValue(
        text: 'abc',
        selection: TextSelection(
          baseOffset: 2,
          extentOffset: 3,
        ),
      ));
    });

    test('test digits only formatter', () {
      final TextEditingValue actualValue =
          FilteringTextInputFormatter.digitsOnly
              .formatEditUpdate(testOldValue, testNewValue);

      // Expecting
      // 1(234)56
      expect(actualValue, const TextEditingValue(
        text: '123456',
        selection: TextSelection(
          baseOffset: 1,
          extentOffset: 4,
        ),
      ));
    });

    test('test digits only formatter (deprecated names)', () {
      final TextEditingValue actualValue =
          FilteringTextInputFormatter.digitsOnly
              .formatEditUpdate(testOldValue, testNewValue);

      // Expecting
      // 1(234)56
      expect(actualValue, const TextEditingValue(
        text: '123456',
        selection: TextSelection(
          baseOffset: 1,
          extentOffset: 4,
        ),
      ));
    });

    test('test length limiting formatter', () {
      final TextEditingValue actualValue =
      LengthLimitingTextInputFormatter(6)
          .formatEditUpdate(testOldValue, testNewValue);

      // Expecting
      // a1b(2c3)
      expect(actualValue, const TextEditingValue(
        text: 'a1b2c3',
        selection: TextSelection(
          baseOffset: 3,
          extentOffset: 6,
        ),
      ));
    });

    test('test length limiting formatter with zero-length string', () {
      testNewValue = const TextEditingValue(
        text: '',
        selection: TextSelection(
          baseOffset: 0,
          extentOffset: 0,
        ),
      );

      final TextEditingValue actualValue =
      LengthLimitingTextInputFormatter(1)
        .formatEditUpdate(testOldValue, testNewValue);

      // Expecting the empty string.
      expect(actualValue, const TextEditingValue(
        text: '',
        selection: TextSelection(
          baseOffset: 0,
          extentOffset: 0,
        ),
      ));
    });

    test('test length limiting formatter with non-BMP Unicode scalar values', () {
      testNewValue = const TextEditingValue(
        text: '\u{1f984}\u{1f984}\u{1f984}\u{1f984}', // Unicode U+1f984 (UNICORN FACE)
        selection: TextSelection(
          // Caret is at the end of the string.
          baseOffset: 8,
          extentOffset: 8,
        ),
      );

      final TextEditingValue actualValue =
      LengthLimitingTextInputFormatter(2)
        .formatEditUpdate(testOldValue, testNewValue);

      // Expecting two characters, with the caret moved to the new end of the
      // string.
      expect(actualValue, const TextEditingValue(
        text: '\u{1f984}\u{1f984}',
        selection: TextSelection(
          baseOffset: 4,
          extentOffset: 4,
        ),
      ));
    });

    test('test length limiting formatter with complex Unicode characters', () {
      // TODO(gspencer): Test additional strings. We can do this once the
      // formatter supports Unicode grapheme clusters.
      //
      // A formatter with max length 1 should accept:
      //  - The '\u{1F3F3}\u{FE0F}\u{200D}\u{1F308}' sequence (flag followed by
      //    a variation selector, a zero-width joiner, and a rainbow to make a rainbow
      //    flag).
      //  - The sequence '\u{0058}\u{0346}\u{0361}\u{035E}\u{032A}\u{031C}\u{0333}\u{0326}\u{031D}\u{0332}'
      //    (Latin X with many composed characters).
      //
      // A formatter should not count as a character:
      //   * The '\u{0000}\u{FEFF}' sequence. (NULL followed by zero-width no-break space).
      //
      // A formatter with max length 1 should truncate this to one character:
      //   * The '\u{1F3F3}\u{FE0F}\u{1F308}' sequence (flag with ignored variation
      //     selector followed by rainbow, should truncate to just flag).

      // The U+1F984 U+0020 sequence: Unicorn face followed by a space should
      // yield only the unicorn face.
      testNewValue = const TextEditingValue(
        text: '\u{1F984}\u{0020}',
        selection: TextSelection(
          baseOffset: 1,
          extentOffset: 1,
        ),
      );
      TextEditingValue actualValue = LengthLimitingTextInputFormatter(1).formatEditUpdate(testOldValue, testNewValue);
      expect(actualValue, const TextEditingValue(
        text: '\u{1F984}',
        selection: TextSelection(
          baseOffset: 1,
          extentOffset: 1,
        ),
      ));

      // The U+0058 U+0059 sequence: Latin X followed by Latin Y, should yield
      // Latin X.
      testNewValue = const TextEditingValue(
        text: '\u{0058}\u{0059}',
        selection: TextSelection(
          baseOffset: 1,
          extentOffset: 1,
        ),
      );
      actualValue = LengthLimitingTextInputFormatter(1).formatEditUpdate(testOldValue, testNewValue);
      expect(actualValue, const TextEditingValue(
        text: '\u{0058}',
        selection: TextSelection(
          baseOffset: 1,
          extentOffset: 1,
        ),
      ));
    });


    test('test length limiting formatter when selection is off the end', () {
      final TextEditingValue actualValue =
      LengthLimitingTextInputFormatter(2)
          .formatEditUpdate(testOldValue, testNewValue);

      // Expecting
      // a1()
      expect(actualValue, const TextEditingValue(
        text: 'a1',
        selection: TextSelection(
          baseOffset: 2,
          extentOffset: 2,
        ),
      ));
    });
  });

  group('LengthLimitingTextInputFormatter', () {
    group('truncate', () {
      test('Removes characters from the end', () async {
        const TextEditingValue value = TextEditingValue(
          text: '01234567890',
          selection: TextSelection.collapsed(offset: -1),
          composing: TextRange.empty,
        );
        final TextEditingValue truncated = LengthLimitingTextInputFormatter
            .truncate(value, 10);
        expect(truncated.text, '0123456789');
      });

      test('Counts surrogate pairs as single characters', () async {
        const String stringOverflowing = '😆01234567890';
        const TextEditingValue value = TextEditingValue(
          text: stringOverflowing,
          // Put the cursor at the end of the overflowing string to test if it
          // ends up at the end of the new string after truncation.
          selection: TextSelection.collapsed(offset: stringOverflowing.length),
          composing: TextRange.empty,
        );
        final TextEditingValue truncated = LengthLimitingTextInputFormatter
            .truncate(value, 10);
        const String stringTruncated = '😆012345678';
        expect(truncated.text, stringTruncated);
        expect(truncated.selection.baseOffset, stringTruncated.length);
        expect(truncated.selection.extentOffset, stringTruncated.length);
      });

      test('Counts grapheme clustsers as single characters', () async {
        const String stringOverflowing = '👨‍👩‍👦01234567890';
        const TextEditingValue value = TextEditingValue(
          text: stringOverflowing,
          // Put the cursor at the end of the overflowing string to test if it
          // ends up at the end of the new string after truncation.
          selection: TextSelection.collapsed(offset: stringOverflowing.length),
          composing: TextRange.empty,
        );
        final TextEditingValue truncated = LengthLimitingTextInputFormatter
            .truncate(value, 10);
        const String stringTruncated = '👨‍👩‍👦012345678';
        expect(truncated.text, stringTruncated);
        expect(truncated.selection.baseOffset, stringTruncated.length);
        expect(truncated.selection.extentOffset, stringTruncated.length);
      });
    });

    group('formatEditUpdate', () {
      const int maxLength = 10;

      test('Passes through when under limit', () async {
        const TextEditingValue oldValue = TextEditingValue(
          text: 'aaa',
          selection: TextSelection.collapsed(offset: -1),
          composing: TextRange.empty,
        );
        const TextEditingValue newValue = TextEditingValue(
          text: 'aaab',
          selection: TextSelection.collapsed(offset: -1),
          composing: TextRange.empty,
        );
        final LengthLimitingTextInputFormatter formatter =
            LengthLimitingTextInputFormatter(maxLength);
        final TextEditingValue formatted = formatter.formatEditUpdate(
          oldValue,
          newValue
        );
        expect(formatted.text, newValue.text);
      });

      test('Uses old value when at the limit', () async {
        const TextEditingValue oldValue = TextEditingValue(
          text: 'aaaaaaaaaa',
          selection: TextSelection.collapsed(offset: -1),
          composing: TextRange.empty,
        );
        const TextEditingValue newValue = TextEditingValue(
          text: 'aaaaabbbbbaaaaa',
          selection: TextSelection.collapsed(offset: -1),
          composing: TextRange.empty,
        );
        final LengthLimitingTextInputFormatter formatter =
            LengthLimitingTextInputFormatter(maxLength);
        final TextEditingValue formatted = formatter.formatEditUpdate(
          oldValue,
          newValue
        );
        expect(formatted.text, oldValue.text);
      });

      test('Truncates newValue when oldValue already over limit', () async {
        const TextEditingValue oldValue = TextEditingValue(
          text: 'aaaaaaaaaaaaaaaaaaaa',
          selection: TextSelection.collapsed(offset: -1),
          composing: TextRange.empty,
        );
        const TextEditingValue newValue = TextEditingValue(
          text: 'bbbbbbbbbbbbbbbbbbbb',
          selection: TextSelection.collapsed(offset: -1),
          composing: TextRange.empty,
        );
        final LengthLimitingTextInputFormatter formatter =
            LengthLimitingTextInputFormatter(maxLength);
        final TextEditingValue formatted = formatter.formatEditUpdate(
          oldValue,
          newValue
        );
        expect(formatted.text, 'bbbbbbbbbb');
      });
    });
  });

  test('FilteringTextInputFormatter should return the old value if new value contains non-white-listed character', () {
    const TextEditingValue oldValue = TextEditingValue(text: '12345');
    const TextEditingValue newValue = TextEditingValue(text: '12345@');

    final TextInputFormatter formatter = FilteringTextInputFormatter.digitsOnly;
    final TextEditingValue formatted = formatter.formatEditUpdate(oldValue, newValue);

    // assert that we are passing digits only at the first time
    expect(oldValue.text, equals('12345'));
    // The new value is always the oldValue plus a non-digit character (user press @)
    expect(newValue.text, equals('12345@'));
    // we expect that the formatted value returns the oldValue only since the newValue does not
    // satisfy the formatter condition (which is, in this case, digitsOnly)
    expect(formatted.text, equals('12345'));
  });

  test('FilteringTextInputFormatter should move the cursor to the right position', () {
    TextEditingValue collapsedValue(String text, int offset) =>
        TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: offset),
        );

    TextEditingValue oldValue = collapsedValue('123', 0);
    TextEditingValue newValue = collapsedValue('123456', 6);

    final TextInputFormatter formatter = FilteringTextInputFormatter.digitsOnly;
    TextEditingValue formatted = formatter.formatEditUpdate(oldValue, newValue);

    // assert that we are passing digits only at the first time
    expect(oldValue.text, equals('123'));
    // assert that we are passing digits only at the second time
    expect(newValue.text, equals('123456'));
    // assert that cursor is at the end of the text
    expect(formatted.selection.baseOffset, equals(6));

    // move cursor at the middle of the text and then add the number 9.
    oldValue = newValue.copyWith(selection: const TextSelection.collapsed(offset: 4));
    newValue = oldValue.copyWith(text: '1239456');

    formatted = formatter.formatEditUpdate(oldValue, newValue);

    // cursor must be now at fourth position (right after the number 9)
    expect(formatted.selection.baseOffset, equals(4));
  });

  test('FilteringTextInputFormatter should remove non-allowed characters', () {
    const TextEditingValue oldValue = TextEditingValue(text: '12345');
    const TextEditingValue newValue = TextEditingValue(text: '12345@');

    final TextInputFormatter formatter = FilteringTextInputFormatter.digitsOnly;
    final TextEditingValue formatted = formatter.formatEditUpdate(oldValue, newValue);

    // assert that we are passing digits only at the first time
    expect(oldValue.text, equals('12345'));
    // The new value is always the oldValue plus a non-digit character (user press @)
    expect(newValue.text, equals('12345@'));
    // we expect that the formatted value returns the oldValue only since the difference
    // between the oldValue and the newValue is only material that isn't allowed
    expect(formatted.text, equals('12345'));
  });

  test('WhitelistingTextInputFormatter should return the old value if new value contains non-allowed character', () {
    const TextEditingValue oldValue = TextEditingValue(text: '12345');
    const TextEditingValue newValue = TextEditingValue(text: '12345@');

    final TextInputFormatter formatter = FilteringTextInputFormatter.digitsOnly;
    final TextEditingValue formatted = formatter.formatEditUpdate(oldValue, newValue);

    // assert that we are passing digits only at the first time
    expect(oldValue.text, equals('12345'));
    // The new value is always the oldValue plus a non-digit character (user press @)
    expect(newValue.text, equals('12345@'));
    // we expect that the formatted value returns the oldValue only since the newValue does not
    // satisfy the formatter condition (which is, in this case, digitsOnly)
    expect(formatted.text, equals('12345'));
  });

  test('FilteringTextInputFormatter should move the cursor to the right position', () {
    TextEditingValue collapsedValue(String text, int offset) =>
        TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: offset),
        );

    TextEditingValue oldValue = collapsedValue('123', 0);
    TextEditingValue newValue = collapsedValue('123456', 6);

    final TextInputFormatter formatter =
        FilteringTextInputFormatter.digitsOnly;
    TextEditingValue formatted = formatter.formatEditUpdate(oldValue,
        newValue);

    // assert that we are passing digits only at the first time
    expect(oldValue.text, equals('123'));
    // assert that we are passing digits only at the second time
    expect(newValue.text, equals('123456'));
    // assert that cursor is at the end of the text
    expect(formatted.selection.baseOffset, equals(6));

    // move cursor at the middle of the text and then add the number 9.
    oldValue = newValue.copyWith(
        selection: const TextSelection.collapsed(offset: 4));
    newValue = oldValue.copyWith(text: '1239456');

    formatted = formatter.formatEditUpdate(oldValue, newValue);

    // cursor must be now at fourth position (right after the number 9)
    expect(formatted.selection.baseOffset, equals(4));
  });

  test('WhitelistingTextInputFormatter should move the cursor to the right position', () {
    TextEditingValue collapsedValue(String text, int offset) =>
        TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: offset),
        );

    TextEditingValue oldValue = collapsedValue('123', 0);
    TextEditingValue newValue = collapsedValue('123456', 6);

    final TextInputFormatter formatter =
        FilteringTextInputFormatter.digitsOnly;
    TextEditingValue formatted = formatter.formatEditUpdate(oldValue,
        newValue);

    // assert that we are passing digits only at the first time
    expect(oldValue.text, equals('123'));
    // assert that we are passing digits only at the second time
    expect(newValue.text, equals('123456'));
    // assert that cursor is at the end of the text
    expect(formatted.selection.baseOffset, equals(6));

    // move cursor at the middle of the text and then add the number 9.
    oldValue = newValue.copyWith(
        selection: const TextSelection.collapsed(offset: 4));
    newValue = oldValue.copyWith(text: '1239456');

    formatted = formatter.formatEditUpdate(oldValue, newValue);

    // cursor must be now at fourth position (right after the number 9)
    expect(formatted.selection.baseOffset, equals(4));
  });
}
