module Spree
  class Promotion < Spree::Activator
    MATCH_POLICIES = %w(all any)
    UNACTIVATABLE_ORDER_STATES = ["complete", "awaiting_return", "returned"]

    Activator.event_names << 'spree.checkout.coupon_code_added'
    Activator.event_names << 'spree.content.visited'

    has_many :promotion_rules, foreign_key: :activator_id, autosave: true, dependent: :destroy
    alias_method :rules, :promotion_rules

    has_many :promotion_actions, foreign_key: :activator_id, autosave: true, dependent: :destroy
    alias_method :actions, :promotion_actions

    accepts_nested_attributes_for :promotion_actions, :promotion_rules

    validates_associated :rules

    validates :name, presence: true
    validates :code, presence: true, if: lambda{|r| r.event_name == 'spree.checkout.coupon_code_added' }
    validates :path, presence: true, if: lambda{|r| r.event_name == 'spree.content.visited' }
    validates :usage_limit, numericality: { greater_than: 0, allow_nil: true }

    def self.advertised
      where(advertise: true)
    end

    def self.with_code
      where(event_name: 'spree.checkout.coupon_code_added')
    end

    def activate(payload)
      if order_activatable?(payload[:order]) && eligible?(payload[:order])
        # make sure code is always downcased (old databases might have mixed case codes)
        if code.present?
          event_code = payload[:coupon_code]
          return unless event_code == self.code.downcase.strip
        end

        if path.present?
          return unless path == payload[:path]
        end

        actions.each do |action|
          action.perform(payload)
        end

        return true
      end
      false
    end

    # called anytime order.update! happens
    def eligible?(order)
      return false if expired? || usage_limit_exceeded?(order)
      rules_are_eligible?(order, {})
    end

    def rules_are_eligible?(order, options = {})
      return true if rules.none?
      eligible = lambda { |r| r.eligible?(order, options) }
      if match_policy == 'all'
        rules.all?(&eligible)
      else
        rules.any?(&eligible)
      end
    end

    def order_activatable?(order)
      order && !UNACTIVATABLE_ORDER_STATES.include?(order.state)
    end

    # Products assigned to all product rules
    def products
      @products ||= self.rules.to_a.inject([]) do |products, rule|
        rule.respond_to?(:products) ? products << rule.products : products
      end.flatten.uniq
    end

    def usage_limit_exceeded?(order = nil)
      usage_limit.present? && usage_limit > 0 && adjusted_credits_count(order) >= usage_limit
    end

    def adjusted_credits_count(order)
      return credits_count if order.nil?
      credits_count - (exists_on_order?(order) ? 1 : 0)
    end

    def credits
      Adjustment.eligible.promotion.where(originator_id: actions.map(&:id))
    end

    def credits_count
      credits.count
    end

    def code=(coupon_code)
      write_attribute(:code, (coupon_code.downcase.strip rescue nil))
    end
    
    def exists_on_order?(order)
      actions.any? { |a| a.credit_exists_on_order?(order) }
    end
  end
end
