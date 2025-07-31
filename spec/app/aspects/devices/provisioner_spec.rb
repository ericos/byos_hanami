# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Devices::Provisioner, :db do
  subject(:provisioner) { described_class.new }

  describe "#call" do
    it "answers existing device" do
      device = Factory[:device, mac_address: "A1:B2:C3:D4:E5:F6"]
      result = provisioner.call mac_address: device.mac_address

      expect(result.success).to have_attributes(playlist_id: nil, mac_address: "A1:B2:C3:D4:E5:F6")
    end

    context "with new device" do
      let(:model) { Factory[:model] }

      it "answers device" do
        result = provisioner.call mac_address: "A1:B2:C3:D4:E5:F6", model_id: model.id

        expect(result.success).to have_attributes(
          model_id: model.id,
          mac_address: "A1:B2:C3:D4:E5:F6"
        )
      end

      it "associates device with playlist" do
        device = provisioner.call(mac_address: "A1:B2:C3:D4:E5:F6", model_id: model.id).success
        playlist = Terminus::Repositories::Playlist.new.find device.playlist_id

        expect(playlist).to have_attributes(
          label: "Device #{device.friendly_id}",
          name: "device_#{device.friendly_id.downcase}"
        )
      end

      it "associates playlist item with welcome screen" do
        device = provisioner.call(mac_address: "A1:B2:C3:D4:E5:F6", model_id: model.id).success
        item = Terminus::Repositories::PlaylistItem.new.find_by playlist_id: device.playlist_id
        screen = item.screen

        expect(screen).to have_attributes(
          model_id: model.id,
          label: "Welcome #{device.friendly_id}",
          name: "terminus_welcome_#{device.friendly_id.downcase}"
        )
      end

      it "associates playlist current item with welcome screen" do
        device = provisioner.call(mac_address: "A1:B2:C3:D4:E5:F6", model_id: model.id).success
        playlist = Terminus::Repositories::Playlist.new.find device.playlist_id
        screen = Terminus::Repositories::Screen.new.find playlist.current_item.screen_id

        expect(screen).to have_attributes(
          label: "Welcome #{device.friendly_id}",
          name: "terminus_welcome_#{device.friendly_id.downcase}"
        )
      end

      it "answers failure with invalid foreign key" do
        result = provisioner.call mac_address: "A1:B2:C3:D4:E5:F6", model_id: 666
        expect(result).to be_failure(%(Key (model_id)=(666) is not present in table "model".))
      end
    end
  end
end
