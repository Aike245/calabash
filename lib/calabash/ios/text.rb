module Calabash
  module IOS
    # Methods for entering text and interacting with iOS keyboards.
    module Text
      # @!visibility private
      define_method(:_enter_text) do |text|
        wait_for_keyboard
        existing_text = text_from_keyboard_first_responder
        options = { existing_text: existing_text }
        Calabash::Internal.with_default_device(required_os: :ios) {|device| device.enter_text(text, options)}
      end

      # @!visibility private
      define_method(:_enter_text_in) do |view, text|
        tap(view)
        enter_text(text)
      end

      # @!visibility private
      define_method(:_clear_text) do
        unless view_exists?("* isFirstResponder:1")
          raise 'Cannot clear text. No view has focus'
        end

        clear_text_in("* isFirstResponder:1")
      end

      # @!visibility private
      define_method(:_clear_text_in) do |view|
        unless keyboard_visible?
          tap(view)
          wait_for_keyboard
        end

        unless wait_for_view(view)['text'].empty?
          tap(view)
          tap("UICalloutBarButton marked:'Select All'")
          sleep 0.5
          tap_keyboard_delete_key
        end

        true
      end

      # Returns true if a docked keyboard is visible.
      #
      # A docked keyboard is pinned to the bottom of the view.
      #
      # Keyboards on the iPhone and iPod are docked.
      #
      # @return [Boolean] Returns true if a keyboard is visible and docked.
      def docked_keyboard_visible?
        Calabash::Internal.with_default_device(required_os: :ios) {|device| device.docked_keyboard_visible?}
      end

      # Returns true if an undocked keyboard is visible.
      #
      # A undocked keyboard is floats in the middle of the view.
      #
      # @return [Boolean] Returns false if the device is not an iPad; all
      # keyboards on the iPhone and iPod are docked.
      def undocked_keyboard_visible?
        Calabash::Internal.with_default_device(required_os: :ios) {|device| device.undocked_keyboard_visible?}
      end

      # Returns true if a split keyboard is visible.
      #
      # A split keyboard is floats in the middle of the view and is split to
      # allow faster thumb typing
      #
      # @return [Boolean] Returns false if the device is not an iPad; all
      # keyboards on the Phone and iPod are docked and not split.
      def split_keyboard_visible?
        Calabash::Internal.with_default_device(required_os: :ios) {|device| device.split_keyboard_visible?}
      end

      # Touches the keyboard action key.
      #
      # The action key depends on the keyboard.  Some examples include:
      #
      # * Return
      # * Next
      # * Go
      # * Join
      # * Search
      #
      # Not all keyboards have an action key.  For example, numeric keyboards
      #  do not have an action key.
      #
      # @raise [RuntimeError] If the text cannot be typed.
      # @todo Refactor uia_route to a public API call
      # @todo Move this documentation to the public method
      # @!visibility private
      define_method(:_tap_keyboard_action_key) do |action_key|
        unless action_key.nil?
          raise ArgumentError,
                "An iOS keyboard does not have multiple action keys"
        end

        wait_for_keyboard
        Calabash::Internal.with_default_device(required_os: :ios) {|device| device.tap_keyboard_action_key}
      end

      # @!visibility private
      define_method(:_keyboard_visible?) do
        docked_keyboard_visible? || undocked_keyboard_visible? || split_keyboard_visible?
      end

      # Touches the keyboard delete key.
      #
      # The 'delete' key difficult to find and touch because its behavior
      # changes depending on the iOS version and keyboard type.  Consider the
      # following:
      #
      # On iOS 6, the 'delete' char code is _not_ \b.
      # On iOS 7: The Delete char code is \b on non-numeric keyboards.
      #           On numeric keyboards, the delete key is a button on the
      #           the keyboard.
      #
      # By default, Calabash uses a raw UIAutomaton JavaScript call to tap the
      # element named 'Delete'.  This works well in English localizations for
      # most keyboards.  If you find that it does not work, use the options
      # pass either an translation of 'Delete' for your localization or use the
      # default the escaped keyboard character.
      #
      # @example
      #   # Uses UIAutomation to tap the 'Delete' key or button.
      #   tap_keyboard_delete_key
      #
      #   # Types the \b key.
      #   tap_keyboard_delete_key({:use_escaped_char => true})
      #
      #   # Types the \d key.
      #   tap_keyboard_delete_key({:use_escaped_char => '\d'})
      #
      #   # Uses UIAutomation to tap the 'Slet' key or button.
      #   tap_keyboard_delete_key({:delete_key_label => 'Slet'})
      #
      #   # Don't specify both options!  If :use_escape_sequence is truthy,
      #   # Calabash will ignore the :delete_key_label and try to use an
      #   # escaped character sequence.
      #   tap_keyboard_delete_key({:use_escaped_char => true,
      #                            :delete_key_label => 'Slet'})
      #
      # @param [Hash] options Alternative ways to tap the delete key.
      # @option options [Boolean, String] :use_escaped_char (false) If true,
      #  delete by typing the \b character.  If this value is truthy, but not
      #  'true', they it is expected to be an alternative escaped character.
      # @option options [String] :delete_key_label ('Delete') An alternative
      #  localization of 'Delete'.
      # @todo Need translations of 'Delete' key.
      def tap_keyboard_delete_key(options = {})
        Calabash::Internal.with_default_device(required_os: :ios) {|device| device.tap_keyboard_delete_key(options)}
      end

      # Returns the the text in the first responder.
      #
      # The first responder will be the UITextField or UITextView instance
      # that is associated with the visible keyboard.
      #
      # Returns empty string if no textField or textView elements are found to be
      # the first responder.  Otherwise, it will return the text in the
      # UITextField or UITextField that is associated with the keyboard.
      #
      # @raise [RuntimeError] If there is no visible keyboard.
      def text_from_keyboard_first_responder
        Calabash::Internal.with_default_device(required_os: :ios) {|device| device.text_from_keyboard_first_responder}
      end

      private

      # @!visibility private
      # noinspection RubyStringKeysInHashInspection
      ESCAPED_KEYBOARD_CHARACTERS =
          {
              :action => '\n',

              # This works for some combinations of keyboard types and
              # iOS version.  The current solution is use a raw UIA call
              # to find the 'Delete' key, which may not work in some
              # situations, for example in non-English environments.  The
              # tap_keyboard_delete_key allows an option to us this escape
              # sequence.
              :delete => '\b',

              # These are not supported yet and I am pretty sure that they
              # cannot be touched by passing an escaped character and instead
              # the must be found using UIAutomation calls.  -jmoody
              #'Dictation' => nil,
              #'Shift' => nil,
              #'International' => nil,
              #'More' => nil,
          }
    end
  end
end
