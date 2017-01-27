module Components
  module Chats
    class Chat < React::Component::Base
      require "chat_service"
      # require "marked.min"
      # require "reactrb_express"

      before_mount do
        @chat_service = ChatService.new do | messages |
          state.messages! ((state.messages || []) + messages)
          puts "state messages updated. state.messages: #{state.messages}"
        end
      end

      def render
        div do
          Nav login: method(:login).to_proc
          Messages messages: state.messages
          InputBox chat_service: @chat_service
        end
      end

      def login(user_name)
        @chat_service.login(user_name)
      end

      # def online?
      #   state.messages
      # end

    end

    class Nav < React::Component::Base

      param :login, type: Proc

      before_mount do
        state.current_user_name! nil
        state.user_name_input! ""
      end

      def render
        div do
          input(type: :text, value: state.user_name_input, placeholder: "Enter Your Handle"
          ).on(:change) do |e|
            state.user_name_input! e.target.value
          end
          button(type: :button) { "login!" }.on(:click) do
            login!
          end if valid_new_input?
        end
      end

      def valid_new_input?
        state.user_name_input.present? && state.user_name_input != state.current_user_name
      end

      def login!
        state.current_user_name! state.user_name_input
        params.login(state.user_name_input)
      end

    end

    class Messages < React::Component::Base

      param :messages, type: [Hash]

      def render
        div do
          params.messages.each do |message|
            Message message: message
          end
        end
      end
    end

    class Message < React::Component::Base

      param :message, type: Hash

      def render
        div do
          div { params.message[:from] }
          FormattedDiv markdown: params.message[:message]
          div { Time.at(params.message[:time]).to_s }
        end
      end
    end

    class InputBox < React::Component::Base

      param :chat_service, type: ChatService

      before_mount { state.composition! "" }
      def render
        div do
          div {"Say something: "}
          input(value: state.composition).on(:change) do |e|
            state.composition! e.target.value
          end.on(:key_down) do |e|
            send_message if is_send_key?(e)
          end
          FormattedDiv markdown: state.composition
        end
      end

      def is_send_key?(e)
        (e.char_code == 13 || e.key_code == 13)
      end

      def send_message
        params.chat_service.send(
        message: state.compostion!(""),
        time: Time.now.to_i,
        from: params.chat_service.id
        )
      end

    end

    class FormattedDiv < React::Component::Base

      param :markdown, type: String

      def render
        div do
          params.markdown
        end
      end
    end
end
end
