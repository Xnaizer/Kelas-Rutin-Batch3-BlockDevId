// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SistemAkademik {
    struct Mahasiswa {
        string nama;
        uint256 nim;
        string jurusan;
        uint256[] nilai;
        bool isActive;
    }
    
    mapping(uint256 => Mahasiswa) public mahasiswa;
    mapping(address => bool) public authorized;
    uint256[] public daftarNIM;
    
    event MahasiswaEnrolled(uint256 nim, string nama);
    event NilaiAdded(uint256 nim, uint256 nilai);
    
    modifier onlyAuthorized() {
        require(authorized[msg.sender], "Tidak memiliki akses");
        _;
    }
    
    constructor() {
        authorized[msg.sender] = true;
    }
    
    // TODO: Implementasikan enrollment function
    function enrollment(string memory _nama, string memory _jurusan) public  {
        require(bytes(_nama).length > 0, "Nama Tidak Boleh Kosong!");
        require(bytes(_jurusan).length > 0, "Jurusan Tidak Boleh Kosong!");

        uint256 nimBaru = daftarNIM.length;
        uint256[] memory _nilai;

        if(!mahasiswa[nimBaru].isActive) {
            mahasiswa[nimBaru] = Mahasiswa({
                nama : _nama,
                nim: nimBaru,
                jurusan : _jurusan,
                nilai: _nilai,
                isActive : true

            });

            daftarNIM.push(nimBaru);
        } else {
            revert("Kamu Sudah terdafter!");
        }

        emit MahasiswaEnrolled(nimBaru, _nama);

    }
    // TODO: Implementasikan add grade function
    function addGrade(uint256 _nim, uint8 _NilaiBaru) public onlyAuthorized {
        mahasiswa[_nim].nilai.push(_NilaiBaru);
    }

    // TODO: Implementasikan get student info function
    function getStudent(uint256 _nim) public view returns (
        string memory nama,
        uint256 nim,
        string memory jurusan,
        uint256[] memory nilai,
        bool isActive
    ) {
        Mahasiswa memory mhs = mahasiswa[_nim];
        return (mhs.nama, mhs.nim, mhs.jurusan, mhs.nilai, mhs.isActive);
    }
}