module Components
  module Chats
    class ChatService

      def initialize(&block)
              if React::IsomorphicHelpers.on_opal_client?
                @block = block
                @messages = []
                @user_id = nil
                @socket = Browser::Socket.new("wss://ruby-websockets-chat.herokuapp.com/") do |socket|
                  socket.on :message do |e|
                    data = JSON.parse(`unescape(#{JSON.parse(e.data)[:text]})`)
                    @messages << data
                    @block.call [data] if id
                  end
                end
              end
            end

      def login(user_id)
        @user_id = user_id
        @block.call @messages
      end

      def id
        @user_id
      end

      def send(data = {})
        @socket.send({handle: id, text: `escape(#{data.to_json})`}.to_json)
      end

    end

    class Chat < React::Component::Base

      before_mount do
        @chat_service = ChatService.new do | messages |
          state.messages! ((state.messages || []) + messages)
          puts "state messages updated. state.messages: #{state.messages}"
        end
      end

      def render
        div do
          Nav login: method(:login).to_proc
          puts state.messages.class
          if online?
            Messages messages: state.messages
            InputBox chat_service: @chat_service
          end
        end
      end

      def login(user_name)
        @chat_service.login(user_name)
      end

      def online?
        state.messages
      end

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
        !state.user_name_input.nil? && state.user_name_input != state.current_user_name
      end

      def login!
        state.current_user_name! state.user_name_input
        params.login(state.user_name_input)
      end

    end

    class Messages < React::Component::Base
      param :messages, type: [Hash]

      def render
        div.container do # add the bootstrap .container class here.
          params.messages.each do |message|
            Message message: message
          end
        end
      end
    end

    class Message < React::Component::Base
      param :message, type: Hash

      after_mount :scroll_to_bottom
      after_update :scroll_to_bottom

      def render
       div.row.alternating.message do
         div.col_sm_2 { params.message[:from] }
         FormattedDiv class: "col-sm-8", markdown: params.message[:message]
         div.col_sm_2 { Time.at(params.message[:time]).to_s }
       end
      end

      def scroll_to_bottom
        Element['html, body'].animate({scrollTop: Element[Document].height}, :slow)
      end
    end

    class InputBox < React::Component::Base
      param :chat_service, type: ChatService

      before_mount { state.composition! "" }

      def render
        div.row.form_group.input_box.navbar.navbar_inverse.navbar_fixed_bottom do
          div.col_sm_1.white {"Say: "}
          textarea.col_sm_5(rows: rows, value: state.composition).on(:change) do |e|
            state.composition! e.target.value
          end.on(:key_down) do |e|
            send_message if is_send_key?(e)
          end
          FormattedDiv class: "col-sm-5 white", markdown: state.composition
        end
      end

      def rows
        [state.composition.count("\n") + 1,20].min
      end

      def is_send_key?(e)
        #(e.char_code == 13 || e.key_code == 13)
        (e.char_code == 13 || e.key_code == 13) && (e.meta_key || e.ctrl_key)
      end

      def send_message
        params.chat_service.send(
          message: state.composition!(""),
          time: Time.now.to_i,
          from: params.chat_service.id
        )
      end
    end

    class FormattedDiv < React::Component::Base
      param :markdown, type: String
      collect_other_params_as :attributes

      def render
        div(params.attributes) do # send whatever class is specified on to the outer div
          div({dangerously_set_inner_HTML: { __html: `marked(#{params.markdown}, {sanitize: true })`}})
        end
      end
    end
end
end
