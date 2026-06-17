class AddAdequacyToDialysisSessions < ActiveRecord::Migration[8.0]
  def change
    change_table :dialysis_sessions, bulk: true do |t|
      t.decimal :pre_urea, precision: 6, scale: 2   # pre-dialysis BUN/urea (mg/dL)
      t.decimal :post_urea, precision: 6, scale: 2   # post-dialysis BUN/urea (mg/dL)
      t.decimal :kt_v, precision: 4, scale: 2        # computed dialysis adequacy
      t.decimal :urr, precision: 5, scale: 2         # urea reduction ratio (%)
    end
  end
end
