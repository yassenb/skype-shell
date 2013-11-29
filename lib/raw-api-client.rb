require 'dbus'

module SkypeShell
  class RawAPIClient
    class SkypeClient < DBus::Object
      attr_writer :listener

      def initialize
        super '/com/Skype/Client'
      end

      dbus_interface 'com.Skype.API.Client' do
        dbus_method :Notify, 'in message:s' do |message|
          return unless @listener
          @listener.call(message)
        end
      end
    end

    def initialize
      @dbus = DBus::SessionBus.instance

      @sender = @dbus.service('com.Skype.API').object '/com/Skype'
      @sender.default_iface = 'com.Skype.API'
      @sender.introspect

      @receiver = SkypeClient.new
      @dbus.request_service('com.github.yassenb-skype-shell').export @receiver

      hello
    end

    def send(message, &block)
      @sender.Invoke(message)
    end

    def on_receive(&block)
      raise ArgumentError, 'no block given' unless block_given?
      @receiver.listener = block
    end

    def hello
      send 'NAME skype-shell'
      send 'PROTOCOL 8'
    end

    def run
      main_loop = DBus::Main.new
      main_loop << @dbus
      main_loop.run
    end
  end
end
