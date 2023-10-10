defmodule Customerio.TriggerCampaignTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  describe "Customerio::trigger_campaign" do
    test "Successful campaign trigger" do
      ExVCR.Config.filter_request_headers("Authorization")

      use_cassette "trigger_campaign/pass" do
        assert {:ok, result} = Customerio.trigger_campaign(9, %{data: %{title: "Campaign Test"}})
        assert "{\"id\":47}" == result
      end
    end
  end
end
