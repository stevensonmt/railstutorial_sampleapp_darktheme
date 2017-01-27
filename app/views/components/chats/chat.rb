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

    #   before_mount do
    #     @chat_service = ChatService.new do | messages |
    #       state.messages! ((state.messages || []) + messages)
    #       puts "state messages updated.  state.messages: #{state.messages}"
    #     end
    #   end
    #
    #   def render
    #     div do
    #       if online?
    #         Messages messages: state.messages, chat_service: @chat_service
    #         InputBox chat_service: @chat_service
    #       end
    #     end
    #   end
    #
    #   def login(user_name)
    #     state.messages! nil
    #     @chat_service.login(user_name)
    #   end
    #
    #   def online?
    #   state.messages
    #   end
    #
    #   def user_id
    #   @chat_service.user_id
    #   end
    #
    # end
    #
    # class Nav < React::Component::Base
    #   param :login, type: Proc
    #
    #   before_mount do
    #     state.current_user_name! nil
    #     state.user_name_input! ""
    #   end
    #
    #   def render
    #     div.container do
    #       div.container do
    #         div.navbar_header do
    #           div.reactrb_icon
    #           a.navbar_brand(href: "#", style: {color: "#00d8ff"}) { "ReactRB Chat Room" }
    #         end
    #         div.collapse.navbar_collapse(id: "navbar") do
    #           form.navbar_form.navbar_left(role: :search) do
    #             div.form_group do
    #               input.form_control(type: :text, value: state.user_name_input, placeholder: "Enter Your Handle").on(:change) do |e|
    #                 state.user_name_input! e.target.value
    #               end.on(:key_down) do |e|
    #                 login! if valid_new_input? && e.key_code == 13
    #               end
    #               button.btn.btn_default(type: :button) { span.glyphicon.glyphicon_log_in }.on(:click) do
    #                 login!
    #               end if valid_new_input?
    #             end
    #           end.on(:submit) { |e| e.prevent_default }
    #         end
    #       end
    #     end
    #   end
    #
    #   def valid_new_input?
    #     state.user_name_input.present? && state.user_name_input != state.current_user_name
    #   end
    #
    #   def login!
    #     state.current_user_name! state.user_name_input
    #     params.login(state.user_name_input)
    #   end
    #
    # end
    #
    # class Messages < React::Component::Base
    #
    #   param :messages, type: [Hash]
    #   param :chat_service, type: ChatService
    #
    #   after_mount :scroll_to_bottom
    #   after_update :scroll_to_bottom
    #
    #   def render
    #     div.container do
    #       params.messages.each do |message|
    #         Message user_id: params.chat_service.id, message: message
    #       end
    #     end
    #   end
    #
    #   def scroll_to_bottom
    #     Element['html, body'].animate({scrollTop: Element[Document].height}, :slow)
    #   end
    # end
    #
    # class Message < React::Component::Base
    #
    #   param :message, type: Hash
    #   param :user_id
    #
    #
    #   def render
    #     div.row.alternating.message do
    #       div.col_sm_2 { sender }
    #       FormattedDiv class: "col-sm-8", markdown: params.message[:message]
    #       div.col_sm_2 { formatted_time }
    #     end
    #   end
    #
    #   def sender
    #     if params.message[:from] == params.user_id
    #       "you: "
    #     else
    #       "#{params.message[:from]}:"
    #     end
    #   end
    #
    #   def formatted_time
    #     time = Time.at(params.message[:time])
    #     if Time.now < time+1.day
    #       time.strftime("%I:%M %p")
    #     elsif Time.now < time+7.days
    #       time.strftime("%A")
    #     else
    #       time.strftime("%D %I:%M %p")
    #     end
    #   end
    # end
    #
    # class InputBox < React::Component::Base
    #
    #   param :chat_service, type: ChatService
    #
    #   before_mount { state.composition! "" }
    #
    #   def render
    #     div.row.form_group.input_box.navbar.navbar_inverse.navbar_fixed_bottom do
    #       div.col_sm_1.white {"Speak! "}
    #       textarea.col_sm_5(rows: rows, value: state.composition).on(:change) do |e|
    #         state.composition! e.target.value
    #       end.on(:key_down) do |e|
    #         send_message if is_send_key?(e)
    #       end
    #       FormattedDiv class: "col-sm-5 white", markdown: state.composition
    #     end
    #   end
    #
    #   def rows
    #     [state.composition.count("\n") + 1,20].min
    #   end
    #
    #   def is_send_key?(e)
    #     (e.char_code == 13 || e.key_code == 13) && (e.meta_key || e.ctrl_key)
    #   end
    #
    #   def send_message
    #     params.chat_service.send(
    #       message: state.composition!(""),
    #       time: Time.now.to_i,
    #       from: params.chat_service.id
    #     )
    #   end
    # end
    #
    # class FormattedDiv < React::Component::Base
    #
    #   param :markdown, type: String
    #   collect_other_params_as :attributes
    #
    #   def render
    #     div(params.attributes) do
    #       div({dangerously_set_inner_HTML: { __html: `marked(#{params.markdown}, {sanitize: true})`}})
    #     end
    #   end
    # end
end
end
