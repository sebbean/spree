# encoding: utf-8
require 'spec_helper'
require 'email_spec'

describe Spree::OrderMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let(:order) do
    order = stub_model(Spree::Order)
    product = stub_model(Spree::Product, :name => %Q{The "BEST" product})
    variant = stub_model(Spree::Variant, :product => product)
    line_item = stub_model(Spree::LineItem, :variant => variant, :order => order, :quantity => 1, :price => 5)
    order.stub(:line_items => [line_item])
    order
  end

  before do
    Spree::MailMethod.create!(
      :environment => Rails.env,
      :preferred_mails_from => "spree@example.com"
    )
  end
  

  it "doesn't aggressively escape double quotes in confirmation body" do
    confirmation_email = Spree::OrderMailer.confirm_email(order)
    confirmation_email.body.should_not include("&quot;")
  end

  it "confirm_email accepts an order id as an alternative to an Order object" do
    Spree::Order.should_receive(:find!).with(order.id).and_return(order)
    lambda {
      confirmation_email = Spree::OrderMailer.confirm_email(order.id)
    }.should_not raise_error
  end

  it "cancel_email accepts an order id as an alternative to an Order object" do
    Spree::Order.should_receive(:find!).with(order.id).and_return(order)
    lambda {
      cancel_email = Spree::OrderMailer.cancel_email(order.id)
    }.should_not raise_error
  end

  context "only shows eligible adjustments in emails" do
    before do
      order.adjustments.create({:label    => "Eligible Adjustment",
                                :amount   => 10,
                                :eligible => true}, :without_protection => true)

      order.adjustments.create!({:label    => "Ineligible Adjustment",
                                 :amount   => -10,
                                 :eligible => false}, :without_protection => true)
    end

    let!(:confirmation_email) { Spree::OrderMailer.confirm_email(order) }
    let!(:cancel_email) { Spree::OrderMailer.cancel_email(order) }

    specify do
      confirmation_email.body.should_not include("Ineligible Adjustment")
    end

    specify do
      cancel_email.body.should_not include("Ineligible Adjustment")
    end
  end

  context "emails must be translatable" do
    context "en locale" do
      before do
        en_confirm_mail = { :order_mailer => { :confirm_email => { :dear_customer => 'Dear Customer,' } } }
        en_cancel_mail = { :order_mailer => { :cancel_email => { :order_summary_canceled => 'Order Summary [CANCELED]' } } }
        I18n.backend.store_translations :en, en_confirm_mail
        I18n.backend.store_translations :en, en_cancel_mail
        I18n.locale = :en
      end

      context "confirm_email" do
        specify do
          confirmation_email = Spree::OrderMailer.confirm_email(order)
          confirmation_email.body.should include("Dear Customer,")
        end
      end

      context "cancel_email" do
        specify do
          cancel_email = Spree::OrderMailer.cancel_email(order)
          cancel_email.body.should include("Order Summary [CANCELED]")
        end
      end
    end

    context "pt-BR locale" do
      before do
        pt_br_confirm_mail = { :order_mailer => { :confirm_email => { :dear_customer => 'Caro Cliente,' } } }
        pt_br_cancel_mail = { :order_mailer => { :cancel_email => { :order_summary_canceled => 'Resumo da Pedido [CANCELADA]' } } }
        I18n.backend.store_translations :'pt-BR', pt_br_confirm_mail
        I18n.backend.store_translations :'pt-BR', pt_br_cancel_mail
        I18n.locale = :'pt-BR'
      end

      after do
        I18n.locale = I18n.default_locale
      end

      context "confirm_email" do
        specify do
          confirmation_email = Spree::OrderMailer.confirm_email(order)
          confirmation_email.body.should include("Caro Cliente,")
        end
      end

      context "cancel_email" do
        specify do
          cancel_email = Spree::OrderMailer.cancel_email(order)
          cancel_email.body.should include("Resumo da Pedido [CANCELADA]")
        end
      end
    end

    context "using EUR as the currency" do
      before do
        Spree::Config[:currency] = "EUR"
      end

      # Regression test for #2690
      it "doesn't aggressively escape money amounts" do
        confirm_email = Spree::OrderMailer.confirm_email(order)
        confirm_email.body.should_not include("&#x20AC;") # escaped € symbol
        confirm_email.body.should include("The \"BEST\" product  (1) @ €5.00 = €5.00")
        confirm_email.body.should include("Subtotal: €0.00")
        confirm_email.body.should include("Order Total: €0.00")
      end

    end
  end
end
