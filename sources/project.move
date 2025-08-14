module MyModule::CharityNFT {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    
    /// Struct representing a charity NFT collection.
    struct CharityCollection has store, key {
        total_donations: u64,    // Total donations received
        nfts_minted: u64,        // Number of NFTs minted
        min_donation: u64,       // Minimum donation required to mint NFT
        charity_owner: address,  // Owner who can withdraw funds
    }
    
    /// Error codes
    const E_INSUFFICIENT_DONATION: u64 = 1;
    const E_NOT_AUTHORIZED: u64 = 2;
    
    /// Function to create a new charity NFT collection.
    public fun create_charity_collection(owner: &signer, min_donation: u64) {
        let charity_collection = CharityCollection {
            total_donations: 0,
            nfts_minted: 0,
            min_donation,
            charity_owner: signer::address_of(owner),
        };
        move_to(owner, charity_collection);
    }
    
    /// Function for users to donate and mint a charity NFT.
    public fun donate_and_mint_nft(
        donor: &signer, 
        charity_owner: address, 
        donation_amount: u64
    ) acquires CharityCollection {
        let charity = borrow_global_mut<CharityCollection>(charity_owner);
        
        // Check minimum donation requirement
        assert!(donation_amount >= charity.min_donation, E_INSUFFICIENT_DONATION);
        
        // Transfer donation from donor to charity owner
        let donation = coin::withdraw<AptosCoin>(donor, donation_amount);
        coin::deposit<AptosCoin>(charity_owner, donation);
        
        // Update charity collection stats
        charity.total_donations = charity.total_donations + donation_amount;
        charity.nfts_minted = charity.nfts_minted + 1;
        
        // Note: In a full implementation, actual NFT minting would happen here
        // For simplicity, we're just tracking the count
    }
    
    /// Function for charity owner to withdraw collected donations.
    public fun withdraw_donations(
        owner: &signer, 
        amount: u64
    ) acquires CharityCollection {
        let owner_addr = signer::address_of(owner);
        let charity = borrow_global<CharityCollection>(owner_addr);
        
        // Verify owner authorization
        assert!(owner_addr == charity.charity_owner, E_NOT_AUTHORIZED);
        
        // Transfer funds from charity to owner (for charitable use)
        let withdrawal = coin::withdraw<AptosCoin>(owner, amount);
        coin::deposit<AptosCoin>(owner_addr, withdrawal);
    }
}