<?php namespace EPlacas\Pessoa;

use EPlacas\Model;
use Illuminate\Database\Eloquent\SoftDeletingTrait;

class Pessoa extends Model
{
    const
    STATUS_ATIVO       = 'A',
    STATUS_INATIVO     = 'I',
    IS_NOT_SOLICITANTE = 'N',
    IS_SOLICITANTE     = 'S';

    use SoftDeletingTrait;

    /**
     * The database table used by the model.
     *
     * @var string
     */
    protected $table = 'Bludata.Pessoa';

    /**
     * Primary key of table
     * @var string
     */
    protected $primaryKey = 'Id';

    protected $fillable = array('nome',
                                'cpf',
                                'rg',
                                'orgao',
                                'rgUf',
                                'dataNascimento',
                                'nomePai',
                                'nomeMae',
                                'site',
                                'status',
                                'EnderecoId',
                                'UsuarioId',
                                'NaturalidadeId',
                                'EstadoCivilId',
                                'NacionalidadeId',
                                'email',
                                'SexoId',
                                'InstituicaoId',
                                'isSolicitante');

    protected $guarded = [];

    protected $dates = array('dataNascimento','deleted_at');

    public static function name()
    {
        return 'Pessoa';
    }

    public function storeRules()
    {
        return array(
        'nome'            => 'required|between:3,150',
        'cpf'             => 'required|cpf',
        'rg'              => 'required|min:3|max:20',
        'orgao'           => 'required|between:1,20',
        'rgUf'            => 'required|size:2|exists:Bludata.Estado,sigla',
        'dataNascimento'  => 'date',
        'nomePai'         => 'between:3,150',
        'nomeMae'         => 'between:3,150',
        'site'            => 'url|max:255',
        'email'           => 'email|max:80',
        'status'          => 'required|size:1|in:A,I',
        'EnderecoId'      => 'integer|exists:Bludata.Endereco,Id',
        'NacionalidadeId' => 'integer|exists:Bludata.Nacionalidade,Id',
        'SexoId'          => 'integer|exists:Bludata.Sexo,Id',
        'EstadoCivilId'   => 'integer|exists:Bludata.EstadoCivil,Id',
        'InstituicaoId'   => 'required|integer|exists:Bludata.Instituicao,Id',
        'isSolicitante'   => 'in:S,N',
        );
    }

    public function updateRules()
    {
        return array(
        'nome'            => 'between:3,150',
        'cpf'             => 'cpf',
        'rg'              => 'min:3|max:20',
        'orgao'           => 'between:1,20',
        'rgUf'            => 'size:2|exists:Bludata.Estado,sigla',
        'dataNascimento'  => 'date',
        'nomePai'         => 'between:3,150',
        'nomeMae'         => 'between:3,150',
        'site'            => 'url|max:255',
        'email'           => 'email|max:80',
        'status'          => 'size:1|in:A,I',
        'EnderecoId'      => 'integer|exists:Bludata.Endereco,Id',
        'NacionalidadeId' => 'integer|exists:Bludata.Nacionalidade,Id',
        'SexoId'          => 'integer|exists:Bludata.Sexo,Id',
        'EstadoCivilId'   => 'integer|exists:Bludata.EstadoCivil,Id',
        'InstituicaoId'   => 'integer|exists:Bludata.Instituicao,Id',
        'isSolicitante'   => 'in:S,N',
        );
    }

    public function getDescriptionAttribute()
    {
        return sprintf('%s', $this->nome);
    }

    public function isSolicitante()
    {
        return $this->isSolicitante == self::IS_SOLICITANTE;
    }

    /**
     * Pessoa tem varios documentos
     *
     * `Pessoa::find(1)->documentos()`
     *
     * @return array
     */
    public function documentos()
    {
        return $this->hasMany('EPlacas\Documento\Documento', 'PessoaId');
    }

    /**
     * Pessoa tem um usuario
     *
     * EX: `Pessoa::find(1)->usuario()`
     *
     * @return User
     */
    public function user()
    {
        return $this->hasOne('\User', 'Id', 'UsuarioId');
    }

    /**
     * Pessoa tem um endereco
     *
     * EX: `Pessoa::find(1)->endereco()`
     *
     * @return EPlacas\Pessoa\Endereco
     */
    public function endereco()
    {
        return $this->hasOne('EPlacas\Pessoa\Endereco', 'Id', 'EnderecoId');
    }

    /**
     * Pessoa tem uma naturalidade
     *
     * EX: `Pessoa::find(1)->naturalidade()`
     *
     * @return EPlacas\Pessoa\Naturalidade
     */
    public function naturalidade()
    {
        return $this->hasOne('EPlacas\Pessoa\Naturalidade', 'Id', 'NaturalidadeId');
    }

    /**
     * Pessoa tem uma nacionalidade
     *
     * `Pessoa::find(1)->nacionalidade()`
     *
     * @return EPlacas\Pessoa\Nacionalidade
     */
    public function nacionalidade()
    {
        return $this->hasOne('EPlacas\Pessoa\Nacionalidade', 'Id', 'NacionalidadeId');
    }

    /**
     * Pessoa tem um sexo
     *
     * `Pessoa::find(1)->sexo()`
     *
     * @return EPlacas\Pessoa\Sexo
     */
    public function sexo()
    {
        return $this->hasOne('EPlacas\Pessoa\Sexo', 'Id', 'SexoId');
    }

    /**
     * Pessoa tem um estado civil
     *
     * `Pessoa::find(1)->estadoCivil()`
     *
     * @return EPlacas\Pessoa\EstadoCivil
     */
    public function estadoCivil()
    {
        return $this->hasOne('EPlacas\Pessoa\EstadoCivil', 'Id', 'EstadoCivilId');
    }

    /**
     * Pessoa possui vários telefones
     *
     * `Pessoa::find(1)->telefone()`
     *
     * @return EPlacas\Pessoa\Telefone
     */
    public function telefones()
    {
        return $this->hasMany('EPlacas\Pessoa\Telefone', 'PessoaId');
    }

    /**
     * Pessoa tem um Instituicao
     *
     * `Pessoa::find(1)->instituicao`
     *
     * @return EPlacas\Instituicao\Instituicao
     */
    public function instituicao()
    {
        return $this->hasOne('EPlacas\Instituicao\Instituicao', 'Id', 'InstituicaoId');
    }


    /**
     * Usuário tem uma Biometria
     * @return EPlacas\Biometria\Biometria
     */
    public function biometria()
    {
        return $this->hasOne('EPlacas\Biometria\Biometria', 'Id', 'BiometriaId');
    }
}
