module openedu::NFT {
    friend openedu::NFTBOX;
    use sui::object;
    use sui::url;
    use sui::tx_context;
    use sui::transfer;
    use std::string::{Self, String};
    

    // Define the NFT struct
    struct EDUNFT has key, store {
        id: object::UID,
        name: string::String,
        link: url::Url,
        image_url: url::Url,
        description: string::String,
        creator: address,
        owner: address,
    }

    public(friend) fun mint(
        name: string::String,
        link: vector<u8>,
        image_url: vector<u8>,
        description: string::String,
        creator: address,
        owner: address,
        ctx: &mut tx_context::TxContext,
    ): EDUNFT {
        let id = object::new(ctx);
        EDUNFT {
            id,
            name,
            link: url::new_unsafe_from_bytes(link),
            image_url: url::new_unsafe_from_bytes(image_url),
            description,
            creator,
            owner,
        }
      
    }

    public fun update_name(_nft: &mut EDUNFT, _name: vector<u8>){
        _nft.name = string::utf8(_name);
    }
    public fun get_name(nft: &EDUNFT):&String{
        &nft.name
    }
    public fun update_link(_nft: &mut EDUNFT, _link: vector<u8>){
        _nft.link = url::new_unsafe_from_bytes(_link);
    }
    public fun get_link(nft: &EDUNFT):&url::Url{
        &nft.link
    }
    public fun update_image_url(_nft: &mut EDUNFT, _image_url: vector<u8>){
        _nft.image_url = url::new_unsafe_from_bytes(_image_url);
    }
    public fun get_image_url(nft: &EDUNFT):&url::Url{
        &nft.image_url
    }
    public fun update_description(_nft: &mut EDUNFT, _description: vector<u8>){
        _nft.description = string::utf8(_description);
    }
    public fun get_description(nft: &EDUNFT):&String{
        &nft.description
    }

    #[test_only]
    public fun mint_for_test(
        name: string::String,
        link: vector<u8>,
        image_url: vector<u8>,
        description: string::String,
        creator: address,
        owner: address,
        ctx: &mut tx_context::TxContext,
    ):EDUNFT {
        mint(name, link, image_url, description, creator, owner, ctx)
    }
}

#[test_only]
module openedu::NFT_FOR_TEST{
    use openedu::NFT::{Self, EDUNFT};
    use sui::test_scenario as ts;
    use sui::transfer;
    use sui::url;
    use std::string;

    #[test]
    fun mint_test(){
        let addr1 = @0xA;
        let addr2 = @0xB;

        let scenario = ts::begin(addr1);
        {
            let nft = NFT::mint_for_test(
                std::string::utf8(b"name"),
                b"link",
                b"image_url",
                std::string::utf8(b"desciption"),
                addr1,
                addr1,
                ts::ctx(&mut scenario),
            );
            transfer::public_transfer(nft,addr1);
        };
        ts::next_tx(&mut scenario, addr1);
        {
            let nft = ts::take_from_sender<EDUNFT>(&mut scenario);
            transfer::public_transfer(nft, addr2);
        };
        ts::next_tx(&mut scenario, addr2);
        {
          let nft = ts::take_from_sender<EDUNFT>(&mut scenario);
          NFT::update_name(&mut nft, b"new name");
          assert!(*string::bytes(NFT::get_name(&nft)) == b"new name",0);
          ts::return_to_sender(&mut scenario, nft);
        };
        ts::next_tx(&mut scenario, addr2);
        {
          let nft = ts::take_from_sender<EDUNFT>(&mut scenario);
          NFT::update_link(&mut nft, b"new link");
          assert!(*NFT::get_link(&nft) == url::new_unsafe_from_bytes(b"new link"),0);
          ts::return_to_sender(&mut scenario, nft);
        };
        ts::next_tx(&mut scenario, addr2);
        {
          let nft = ts::take_from_sender<EDUNFT>(&mut scenario);
          NFT::update_image_url(&mut nft, b"new image_url");
          assert!(*NFT::get_image_url(&nft) == url::new_unsafe_from_bytes(b"new image_url"),0);
          ts::return_to_sender(&mut scenario, nft);
        };
        ts::next_tx(&mut scenario, addr2);
        {
          let nft = ts::take_from_sender<EDUNFT>(&mut scenario);
          NFT::update_description(&mut nft, b"new description");
          assert!(*string::bytes(NFT::get_description(&nft)) == b"new description",0);
          ts::return_to_sender(&mut scenario, nft);
        };
        ts::end(scenario);
    }
}