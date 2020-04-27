<?php namespace EPlacas\Pessoa;

use EPlacas\Model;

class Endereco extends Model
{

    /**
     * The database table used by the model.
     *
     * @var string
     */
    protected $table = 'Bludata.Endereco';

    /**
     * Primary key of table
     * @var string
     */
    protected $primaryKey = 'Id';

    /**
     * Campos que podem ser instanciados com mass-assignable
     * @var array
     */
    protected $fillable = array(
                        'logradouro',
                        'numero',
                        'bairro',
                        'cep',
                        'EstadoId',
                        'CidadeId',
                        'complemento');

    protected $guarded = [];

    public static function name()
    {
        return 'Endereço';
    }

    /**
     * Regras de validação
     * @var array
     */
    public function storeRules()
    {
        return array(
        'logradouro' => 'required',
        'numero'     => 'numeric',
        'cep'        => 'numeric',
        'EstadoId'   => 'exists:Bludata.Estado,Id',
        'CidadeId'   => 'exists:Bludata.Cidade,Id',
        );
    }

    public function updateRules()
    {
        return $this->storeRules();
    }

    public function getDescriptionAttribute()
    {
        $return = $this->attributes['logradouro']
         . ', '
          . $this->attributes['numero']
          . ', '
          . $this->attributes['bairro']
          . ' - '
          . $this->attributes['cep'];

        return ucwords($return);
    }

    /**
     * Endereco tem um estado
     * @return Estado
     */
    public function pessoa()
    {
        return $this->belongsTo('EPlacas\Pessoa\Pessoa', 'Id', 'EnderecoId');
    }

    /**
     * Endereco tem um estado
     * @return Estado
     */
    public function estado()
    {
        return $this->hasOne('EPlacas\Localizacao\Estado', 'Id', 'EstadoId');
    }

    /**
     * Endereco tem um estado
     * @return Estado
     */
    public function cidade()
    {
        return $this->hasOne('EPlacas\Localizacao\Cidade', 'Id', 'CidadeId');
    }
}
