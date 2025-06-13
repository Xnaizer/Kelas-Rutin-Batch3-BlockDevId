// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract PemilihanBEM {
    struct Kandidat {
        string nama;
        string visi;
        uint256 suara;
    }
    
    Kandidat[] public kandidat;
    mapping(address => bool) public sudahMemilih;
    mapping(address => bool) public pemilihTerdaftar;
    
    uint256 public waktuMulai;
    uint256 public waktuSelesai;
    address public admin;
    
    event VoteCasted(address indexed voter, uint256 kandidatIndex);
    event KandidatAdded(string nama);

    constructor(uint256 _waktuMulai, uint256 _waktuSelesai) {
        admin = msg.sender;
        waktuMulai = _waktuMulai;
        waktuSelesai = _waktuSelesai;
    }
    
    modifier onlyDuringVoting() {
        require(
            block.timestamp >= waktuMulai && 
            block.timestamp <= waktuSelesai, 
            "Voting belum dimulai atau sudah selesai"
        );
        _;
    }
    
    // TODO: Implementasikan add candidate function
    function addCandidate(string memory _nama, string memory _visi) public {
        require(bytes(_nama).length > 0, "Nama Tidak Boleh Kosong!");
        require(bytes(_visi).length > 0, "Nama Tidak Boleh Kosong!");

        kandidat.push(Kandidat(_nama, _visi, 0));

        emit KandidatAdded(_nama);
    }

    function daftarPemilih(address _pemilih) public {
        require(msg.sender == admin, "Hanya admin yang boleh daftar pemilih");
        pemilihTerdaftar[_pemilih] = true;
    }
    // TODO: Implementasikan vote function
    function vote(uint256 _noCandidate) public onlyDuringVoting {
        require(_noCandidate < kandidat.length, "Masukkan Id dengan benar!");
        // require(waktuMulai < block.timestamp, "Waktu Vote belum dimulai!");
        require(sudahMemilih[msg.sender] == false, "Kamu sudah memilih!");
        require(pemilihTerdaftar[msg.sender] == true, "Kamu bukan pemilih yang terverifikasi!");

        kandidat[_noCandidate].suara += 1;

        sudahMemilih[msg.sender] = true;

        emit VoteCasted(msg.sender, _noCandidate);
    }

    // TODO: Implementasikan get results function
    function getResult(uint256 _noCandidate) public view returns (
        string memory nama,
        string memory visi,
        uint256 suara
    ) {
        Kandidat memory person = kandidat[_noCandidate];

        return (person.nama, person.visi,person.suara);
    }

    function cobaPaksaVote(uint256 _noCandidate) public onlyDuringVoting{
        kandidat[_noCandidate].suara += 1;
    }
}