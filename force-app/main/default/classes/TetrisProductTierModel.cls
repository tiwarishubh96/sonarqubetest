global class TetrisProductTierModel {    
        global String sku {get; set;}
        global Decimal quantity {get; set;}
    	global List<TetrisProductTierModel.TetrisProductTier> tier;
    
    global class TetrisProductTier {
        global String tierAttribute;
        global String tierQuantity;
    }
}